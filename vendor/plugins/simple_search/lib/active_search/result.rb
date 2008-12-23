# A container for ActiveRecords that get retrieved. When getting results of Ferret searches we also
# would like to have access to the additional details, such as search score. The record we have fetched
# is not made to bear these attributes from the get-go, so we deccorate it with a Result

class ActiveSearch::Result
  attr_accessor :result_score
  attr_accessor :document
  attr_reader :record
  include Comparable
  delegate :id, :to => :record
  
  def self.wrap_find(records)
    records.collect{|r| self.new(r)}
  end
  
  def initialize(record)
    @record = record
  end

	# Gives access to the ActiveRecord
	def record
		@record
	end
  
	# Gives passthrough access to the ActiveRecord class
  def class
    @record.class
  end
  
  def method_missing(*args) #:nodoc:
    @record.send(*args)
  end
  
  def self.method_missing(*args) #:nodoc:
    @record.class.send(*args)
  end    
  
	# Allows comparisons to another ActiveRecord
  def <=>(other)
    # First of all check of we are dealing with dupes
    return 0 if (other.record <=> self.record) == 0

    # Then sort by score
    retriever = lambda { | the | [the.record.class, the.record[the.record.class.primary_key], the.result_score] }

    (retriever.call(self) + [result_score]) <=> (retriever.call(other) + [other.result_score])
  end
end