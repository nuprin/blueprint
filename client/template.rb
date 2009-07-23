require 'rubygems'
require 'activesupport'

class Template
  include Enumerable

  attr_reader :fields

  class TemplateField
    attr_reader :id, :order, :commented
    attr_accessor :value

    def initialize(name, id, order=nil, options={})
      @id = id
      @name = name
      @order = order
      @value = ""

      @commented = options[:uncomment] ? false : true
    end

    def name
      @name.to_s.upcase
    end

    def to_sym
      @name.to_sym
    end

    def to_s
      str = ""
      str += "#" if @commented
      str += "#{name}="
      str += @value.to_s if @value
      str += "\n"
    end

    def to_default_s
      "###{name}##\n#{value}"
    end
  end

  # Constructor
  def initialize
    @fields = []
    @order = 0
    @hidden_fields = HashWithIndifferentAccess.new
  end

  # Template class methods
  def self.from_template(string)
    t = self.new
    t.from_template(string)
    t
  end
  # Template methods

  def add_field(field, identifier, options={})
    field_obj = TemplateField.new(field, identifier, @order, options)
    @fields << field_obj
    set_default_field(field_obj) if options[:default]
    @order += 1
  end

  def set_default_field(field)
    field = @fields.find { |obj| obj.to_sym == field.to_sym}
    @default = field
  end


  def from_template(string)
    keypairs = @fields.map { |f| [f.name, f.id] }
    string.each do |line|
      next if line =~ /^#/

      any_match = false
      keypairs.each do |field_name, field_id|
        regex = /^#{field_name}=/
        if line =~ regex
          self[field_id] = line.gsub(regex, "").strip()
          any_match = true
          break
        end
      end

      @default.value += line if @default && !any_match
    end
  end

  def to_template
    fields = @fields.sort { |a, b| a.order <=> b.order }
    template = ""
    fields.each do |field|
      next if @default && field.to_sym == @default.to_sym
      template += field.to_s
    end
    template += @default.to_default_s if @default
    template
  end

  def to_symbol_hash
    h = {}
    @fields.each do |f|
      h[f.id.to_sym] = f.value if f.value && f.value.strip().any?
    end
    @hidden_fields.each do |key, value|
      h[key.to_sym] = value
    end
    h
  end

  def each
    @fields.each do |field|
      yield field.to_sym
    end
    @hidden_fields.each do |key, val|
      yield key
    end
  end

  def update(values={})
    values.each do |key, val|
      self[key] = val
    end
  end

  def [](field)
    f = @fields.find { |obj| obj.id.to_sym == field.to_sym }
    if f
      f.value if f
    else
      @hidden_fields[field.to_sym]
    end
  end

  def []=(field, value)
    f = @fields.find { |obj| obj.id.to_sym == field.to_sym }
    if f
      f.value = value
    else
      @hidden_fields[field] = value
    end
  end


end

class TaskTemplate < Template
  def initialize
    super
    add_field(:title, "title", :uncomment => true)
    add_field(:assignee, "assignee_email", :uncomment => true)
    add_field(:project, "project_id")
    add_field(:estimate, "estimate")
    add_field(:status, "status")
    add_field(:duedate, "due_date")
    add_field(:description, "description", :default => true)
  end
end
