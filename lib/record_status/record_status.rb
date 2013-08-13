require 'active_support/concern'

module RecordStatus

  STATUSES = {
    'A' => :active,
    'D' => :deleted,
    'H' => :hidden,
    'X' => :administratively_deleted,
    'R' => :reassigned,
    'E' => :expired
  }

  extend ActiveSupport::Concern

  module ClassMethods

    # Sets a default_scope on the model based on the status column.
    # Most of the time, you'll want to show only :active records, e.g.:
    #
    #   default_scope_by_status :record_status, :active
    #
    # If you wish to show extra statuses (in the default scope),
    # you may pass multiple names as an array:
    #
    #   default_scope_by_status :record_status, [:active, :hidden]
    #
    # By default, the status definitions are set to RecordStatus::STATUSES
    # Alternatively, you may specify your own status codes and descriptions
    # by passing the :codes option, e.g.:
    #
    #   default_scope_by_status :record_status, [:active, :hidden], codes: {
    #     'F' => :foo,
    #     'B' => :bar
    #   }
    #
    # The following options will include nil and/or blank values in the
    # default scope:
    #
    #   allow_nil: true
    #   allow_blank: true
    #
    def default_scope_by_status(attr, vals, options={})
      options.symbolize_keys!
      codes = options[:codes] || STATUSES
      vals = [vals] unless Array === vals
      vals = vals.map { |v| codes.invert[v] }.compact
      raise ArgumentError.new('You must supply at least one value') unless vals.any?
      vals << nil if options[:allow_nil]
      vals << '' if options[:allow_blank]
      default_scope { where(["#{quoted_table_name}.#{attr} in (?)", vals]) }
    end

    # Sets up scopes for each status value, given a attribute name:
    #
    #   status :record_status
    #
    # So you can scope to `professional.active`, `professional.hidden`, etc.
    #
    # Also defines a reader and a writer of the same name:
    #
    #   professional.record_status # => :active
    #
    # You may pass the descriptive name to the setter or the actual
    # column value:
    #
    #   professional.record_status = :active
    #   professional.record_status = 'A'     # same effect
    #
    # If you pass an unknown value to the writer, then an exception
    # is raised.
    #
    # You may specify a different name for the reader/writer than the
    # associated field name, by passing the :field option, e.g.:
    #
    #   status :status, field: :record_status
    #
    # Doing so will give you `professional.status` that reads and writes to
    # `professional.record_status` under the hood.
    #
    # By default, the status definitions are set to RecordStatus::STATUSES
    # Alternatively, you may specify your own status codes and descriptions
    # by passing the :codes option, e.g.:
    #
    #   status :record_status, codes: {
    #     'F' => :foo,
    #     'B' => :bar
    #   }
    #
    # You can specify your own default if the attribute is either
    # blank ('') or nil:
    #
    #   status :record_status, default: :active
    #
    def status(attr, options={})
      options.symbolize_keys!
      field = options[:field] || attr
      codes = options[:codes] || STATUSES
      default = options[:default]
      codes.each do |val, label|
        scope label, ->{ where(field => val) }
      end

      define_method attr do
        val = self[field]
        if val.present?
          codes[val.strip]
        else
          default
        end
      end

      define_method attr.to_s + '=' do |name|
        name = name.to_s.strip
        if val = (codes.invert[name.to_sym] || codes.invert[name])
          self[field] = val
        elsif codes[name]
          self[field] = name
        else
          raise ArgumentError.new("Unknown status value '#{name}'")
        end
      end
    end
  end

end
