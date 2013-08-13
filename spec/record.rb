class Record
  cattr_accessor :scopes, :default_scopes

  module ClassMethods
    def scope(*args)
      self.scopes ||= []
      if args.any?
        self.scopes << args
      else
        self.scopes << yield
      end
    end

    def default_scope(*args)
      self.default_scopes ||= []
      if args.any?
        self.default_scopes << args
      else
        self.default_scopes << yield
      end
    end

    def where(*args)
      [:where, *args]
    end

    def quoted_table_name
      "record"
    end
  end

  extend ClassMethods

  def [](attr)
    instance_variable_get(('@' + attr.to_s).to_sym)
  end

  def []=(attr, val)
    instance_variable_set(('@' + attr.to_s).to_sym, val)
  end
end
