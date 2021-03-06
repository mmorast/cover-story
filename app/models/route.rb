class Route < ActiveRecord::Base
  include ResultsLogger

  belongs_to :import_collection
  has_many :route_histories
  alias_method :histories, :route_histories

  scope :inactive, -> { where(inactive: true) }
  scope :active, ->   { where(inactive: [false, nil]) }

  def active?
    !self.inactive?
  end

  def activate(update_all_matches=true)
    if update_all_matches
      routes = self.class.where(path: self.path)
      routes.each do |r|
        return if r.active? # never allow duplication
        r.update_attributes(inactive: nil)
        r.add_history(:active)
      end
      ids = routes.pluck("id").to_sentence
      log_info("+activated route: #{self.path} (IDs: #{ids})")
    else
      return if self.active? # never allow duplication
      update_attributes(inactive: nil)
      add_history(:active)
      id = self.id
      log_info("+activated route: #{self.path} (ID: #{id})")
    end
  end

  def inactivate(update_all_matches=true)
    if update_all_matches
      routes = self.class.where(path: self.path)
      routes.each do |r|
        return if r.inactive? # never allow duplication
        r.update_attributes(inactive: true)
        r.add_history(:inactive)
      end
      ids = routes.pluck("id").to_sentence
      log_info("+inactivated route: #{self.path} (IDs: #{ids})")
    else
      return if self.inactive? # never allow duplication
      update_attributes(inactive: true)
      add_history(:inactive)
      id = self.id
      log_info("-inactivated route: #{self.path} (ID: #{id})")
    end
  end

  def add_history(status)
    histories = self.route_histories
    case status
    when :active
      histories << RouteHistory.new(activated: true)
    when :inactive
      histories << RouteHistory.new(inactivated: true)
    end
  end

  def application
    Formatter.application_from_filename(self.filename)
  end

  def self.paths
    self.pluck('path').uniq
  end

  def self.controllers
    self.pluck('controller').uniq
  end
end
