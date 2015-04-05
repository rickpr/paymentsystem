module Container

  attr_reader :duplicates

  def initialize
    @duplicates ||= []
    self.class.send :create, self
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

    private 

    def create item
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

