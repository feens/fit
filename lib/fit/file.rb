module Fit
  class File

    def self.read(io)
      new.read(io)
    end

    attr_reader :header, :records, :crc

    def initialize
      @records = []
    end

    def read(io)
      @header = Header.read(io)

      Record.clear_definitions!

      while io.pos < @header.end_pos
        @records << Record.read(io)
      end

      @crc = io.read(2)

      self
    end

    def active_duration
      session_value_for(:raw_total_timer_time)
    end

    def distance
      session_value_for(:raw_total_distance)
    end

    def duration
      session_value_for(:raw_total_elapsed_time)
    end

    def end_time
      epoch + session_records.last.raw_timestamp
    end

    def start_time
      epoch + session_records.first.raw_start_time
    end

    private

    # FIT global message numbers
    GLOBAL_MESSAGE_NUMBERS = {
      :file_id => 0,
      :file_creator => 49,
      :software => 35,
      :file_capabilities => 37,
      :mesg_capabilities => 38,
      :field_capabilities => 39,
      :device_settings => 2,
      :user_profile => 3,
      :hrm_profile => 4,
      :sdm_profile => 5,
      :bike_profile => 6,
      :zones_target => 7,
      :sport => 12,
      :hr_zone => 8,
      :power_zone => 9,
      :met_zone => 10,
      :goal => 15,
      :activity => 34,
      :session => 18,
      :lap => 19,
      :record => 20,
      :event => 21,
      :device_info => 23,
      :course => 31,
      :course_point => 32,
      :workout => 26,
      :workout_step => 27,
      :totals => 33,
      :weight_scale => 30,
      :blood_pressure => 51,
    }


    GLOBAL_MESSAGE_NUMBERS.each do |name, global_message_number|
      define_method "#{name}_records" do
        local = local_message_type(global_message_number)

        if local
          local_records(local)
        else
          []
        end
      end
    end


    def session_value_for(method)
      session_records.inject(0) { |sum, record| sum + record.send(method) }
    end

    def epoch
      fit_epoch = Date.new(1989, 12, 31).to_time.to_i
    end

    def local_message_type(global_message_number)
      headers = records.reject { |m| m.content == nil }

      headers.select! do |m|
        m.content["global_message_number"] == global_message_number
      end

      case headers.count
      when 1
        headers.first.header["local_message_type"]
      else
        nil
      end
    end

    def local_records(local_message_type)
      locals = records.select do |m|
        m.header["local_message_type"] == local_message_type
      end

      locals.reject! do |m|
        m.content == nil || m.content["global_message_number"] != nil
      end

      locals.map(&:content)
    end
  end
end
