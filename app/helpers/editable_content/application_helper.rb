module EditableContent::ApplicationHelper
	include Mercury::Authentication

	def editable_content(name = nil, wrapper = :div, args = {}, &block)
		contents = capture(&block)
		if wrapper.is_a? Hash
			args = args.merge(wrapper)
			wrapper = :div
		end
		if name.is_a? Symbol
			wrapper = name
			name = nil
		else
			if name.is_a? Hash
				args = args.merge(name)
				name = nil
			end
		end
		key = Digest::MD5.hexdigest(name ? name : contents)
		e = ::EditableContent::Editable.find_by_key(key) || ::EditableContent::Editable.create(:key => key, :text => contents)
		contents = e.text if !e.text.empty?

		if can_edit?
			options = {'data-key' => key, 'data-mercury' => 'full'}
			options = args.merge(options)
			return content_tag(wrapper, contents.html_safe, options) 
		else
			return content_tag(wrapper, contents.html_safe, args) 
		end
	end

	def editable_image_tag(src, *args)
		options = args.extract_options!
		size = options[:size]
		if !size
			raise "The attribute :size must be specified on editable_image_tag"
		end

		key = Digest::MD5.hexdigest(src)
		if @editable = ::EditableContent::Editable.where(:key => key).first
			src = @editable.src
		else
			@editable = ::EditableContent::Editable.create(:key => key, :src => src)
		end

		if can_edit?
			image_tag(src, options.merge({:id => key, "data-size" => size, "data-mercury" => "image"}))
		else
			image_tag(src, options) 
		end
	end

end