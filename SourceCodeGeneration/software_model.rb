require 'set'
require '.\sequence_parser'

class Event 
  attr_accessor :name, :params

  def initialize(seq_file_line)
    @params = Hash.new # Hash as : field_name => field_value

    if seq_file_line =~ /^(\w+)(\(.*\))?$/ then
      @name = $1
      left_str = $2
      while left_str =~ /((\w+)=([\w"]+)),?(.*)/
        @params[$2] = $3
        left_str = $4
      end
    end
  end

  def merge_params(other_event)
    @params.merge! other_event.params
  end

  def == (other)
    return other != nil && name == other.name
  end

  def eql?(other)
    self == other
  end

end

class StateMachine

  attr_accessor :module_name, :states, :events

  def initialize(module_name)
    @module_name = module_name
    @states = Set.new 
    @events = Set.new
  end

end

class SoftwareModel

  attr_accessor :module_name, :state_machine
  
  def initialize(module_name)
    @state_machine = StateMachine.new(module_name)
    @module_name = module_name
  end

  def get_information_from_sequence(seq_parser)
    seq_parser.focus_on_component @module_name
    seq_parser.get_all_events.map {|e| Event.new(e)}.each do |new_e|
      if ! @state_machine.events.find {|e| e.name == new_e.name }&.merge_params(new_e)
        @state_machine.events << new_e
      end
    end
    @state_machine.states.merge seq_parser.get_all_states
  end

end


