#
# create_ini_settings.rb
#
module Puppet::Parser::Functions
  newfunction(:create_ini_settings, type: :statement, doc: <<-EOS
    Uses create_resources to create a set of ini_setting resources from a hash:

        $settings = {  section1 => {
            setting1 => val1
          },
          section2 => {
            setting2 => val2,
            setting3 => {
              ensure => absent
            }
          }
        }
        $defaults = {
          path => '/tmp/foo.ini'
        }
        create_ini_settings($settings,$defaults)


    Will create the following resources

        ini_setting{'/tmp/foo.ini [section1] setting1':
          ensure  => present,
          section => 'section1',
          setting => 'setting1',
          value   => 'val1',
          path    => '/tmp/foo.ini',
        }
        ini_setting{'/tmp/foo.ini [section2] setting2':
          ensure  => present,
          section => 'section2',
          setting => 'setting2',
          value   => 'val2',
          path    => '/tmp/foo.ini',
        }
        ini_setting{'/tmp/foo.ini [section2] setting3':
          ensure  => absent,
          section => 'section2',
          setting => 'setting3',
          path    => '/tmp/foo.ini',
        }

    EOS
             ) do |arguments|

    unless arguments.size.between?(1, 2)
      raise(Puppet::ParseError, _('create_ini_settings(): Wrong number of arguments ' \
        'given (%{arguments_size} for 1 or 2)')) % { arguments_size: arguments.size }
    end

    settings = arguments[0]
    defaults = arguments[1] || {}

    if [settings, defaults].any? { |i| !i.is_a?(Hash) }
      raise(Puppet::ParseError,
            _('create_ini_settings(): Requires all arguments to be a Hash'))
    end

    resources = settings.keys.each_with_object({}) do |section, res|
      unless settings[section].is_a?(Hash)
        raise(Puppet::ParseError,
              _('create_ini_settings(): Section %{section} must contain a Hash')) % { section: section }
      end

      path = defaults.merge(settings)['path']
      raise Puppet::ParseError, _('create_ini_settings(): must pass the path parameter to the Ini_setting resource!') unless path

      settings[section].each do |setting, value|
        res["#{path} [#{section}] #{setting}"] = {
          'ensure'  => 'present',
          'section' => section,
          'setting' => setting,
        }.merge(if value.is_a?(Hash)
                  value
                else
                  { 'value' => value }
                end)
      end
    end

    Puppet::Parser::Functions.function('create_resources')
    function_create_resources(['ini_setting', resources, defaults])
  end
end

# vim: set ts=2 sw=2 et :
