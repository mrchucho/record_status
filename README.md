## Record Status

To automatically include this in **all** ActiveRecord model classes, add the
following to ```config/initializers/record_status.rb```
```ruby
ActiveRecord::Base.send :include, RecordStatus
```
