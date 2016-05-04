#encoding: utf-8

require 'date'

module VmstatCat
  module CreatedAt
    def created_at
      fill_0 = lambda{|val|
        format("%02d", val)
      }
      oclock = Time.now
      
      y = oclock.year.to_s
      m = fill_0.call(oclock.month)
      d = fill_0.call(oclock.day)
      
      h = fill_0.call(oclock.hour)
      mi = fill_0.call(oclock.min)
      s = fill_0.call(oclock.sec)
      
      "#{y + m + d}_#{h + mi + s}"
    end
  end
  CreatedAt.freeze
end