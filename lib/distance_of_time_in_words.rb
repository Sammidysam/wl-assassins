module DistanceOfTimeInWords
    def precise_distance_of_time_in_words(from_time, to_time, options = {})
		return "no time" if options[:no_time] && from_time < to_time

		from_time = from_time.to_time if from_time.respond_to?(:to_time)
		to_time = to_time.to_time if to_time.respond_to?(:to_time)
		distance_in_seconds = ((to_time - from_time).abs).round
		components = []

		split = %w(year month week day hour minute)
		if options[:interval]
			split = split[split.index(options[:interval].to_s)..split.length]
		end

		split.each do |interval|
			# For each interval type, if the amount of time remaining is greater than
			# one unit, calculate how many units fit into the remaining time.
			if distance_in_seconds >= 1.send(interval)
				delta = (distance_in_seconds / 1.send(interval)).floor
				distance_in_seconds -= delta.send(interval)

				if options[:interval]
					components = delta if options[:interval].to_s == interval
				else
					components << pluralize(delta, interval)
				end
			end
		end

		components = 0 if options[:interval] && !components.is_a?(Fixnum)

		components.is_a?(Array) ? components.to_sentence : components
	end

	def precise_distance_of_time_in_words_to_now(from_time, options = {})
		precise_distance_of_time_in_words from_time, DateTime.now, options
	end
end
