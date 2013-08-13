## Record Status

This gem adds functionality for handling common record status operations.

### Default scope by status

Sets a default_scope on the model based on the status column.
Most of the time, you'll want to show only :active records, e.g.:
```ruby
  default_scope_by_status :record_status, :active
```
If you wish to show extra statuses (in the default scope),
you may pass multiple names as an array:
```ruby
  default_scope_by_status :record_status, [:active, :hidden]
```
By default, the status definitions are set to RecordStatus::STATUSES
Alternatively, you may specify your own status codes and descriptions
by passing the :codes option, e.g.:
```ruby
  default_scope_by_status :record_status, [:active, :hidden], codes: {
    'F' => :foo,
    'B' => :bar
  }
```
The following options will include nil and/or blank values in the
default scope:
```ruby
  allow_nil: true
  allow_blank: true
```

### Status scopes

Sets up scopes for each status value, given a attribute name:
```ruby
  status :record_status
```
So you can scope to `professional.active`, `professional.hidden`, etc.

Also defines a reader and a writer of the same name:
```ruby
  professional.record_status # => :active
```
You may pass the descriptive name to the setter or the actual
column value:
```ruby
  professional.record_status = :active
  professional.record_status = 'A'     # same effect
```
If you pass an unknown value to the writer, then an exception
is raised.

You may specify a different name for the reader/writer than the
associated field name, by passing the :field option, e.g.:
```ruby
  status :status, field: :record_status
```
Doing so will give you `professional.status` that reads and writes to
`professional.record_status` under the hood.

By default, the status definitions are set to RecordStatus::STATUSES
Alternatively, you may specify your own status codes and descriptions
by passing the :codes option, e.g.:
```ruby
  status :record_status, codes: {
    'F' => :foo,
    'B' => :bar
  }
```
You can specify your own default if the attribute is either
blank ('') or nil:
```ruby
  status :record_status, default: :active
```

### Installation & Setup

To automatically include this in **all** ActiveRecord model classes, add the
following to ```config/initializers/record_status.rb```
```ruby
ActiveRecord::Base.send :include, RecordStatus
```
