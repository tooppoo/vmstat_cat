#encoding: utf-8

module VmstatCat
  module Config
    test_mode = $0 == __FILE__
    check_require_path = lambda{|timing|
      puts "#{timing}-----------------------"
      puts $:
      puts "--------------------------------"
    }
    check_require_path.call('before') if test_mode
    $: << File::expand_path(__dir__)
    check_require_path.call('after') if test_mode
    
    FOOTER_EXISTS = false
    FOOTER_INDEX = nil
    BODY_RANGE = 22
  end
  Config.freeze
end