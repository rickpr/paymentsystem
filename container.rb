module Container

  attr_reader :duplicates

  def initialize
    @duplicates ||= []
    self.class.create self
  end

  def unique *attributes
    attributes.each do |attribute|
      @duplicates << attribute if self.class.all.map(&attribute).include? send(attribute)
    end
  end

  def delete
    self.class.send :delete, self
  end

  module ClassMethods

    attr_reader :all

    def create item
      return warn "Must be a #{self}" unless item.class == self
      if all.include? item
        warn "Already exists."
      elsif item.duplicates.any?
        item.duplicates.each { |attr| warn "#{item.class} #{attr} must be unique." }
      else
        all.push item
      end
    end

    def delete item
      all.delete item
    end
  end

  private

  def self.included subclass
    subclass.instance_variable_set :@all, []
    subclass.extend ClassMethods 
  end

end

