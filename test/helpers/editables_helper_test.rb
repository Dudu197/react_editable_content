# encoding: utf-8
require 'test_helper'

class EditablesHelperTest < ActionView::TestCase
	include EditableContent::ApplicationHelper

	fixtures :editables
  	set_fixture_class :editables => EditableContent::Editable

	setup do
		self.stubs(:can_edit?).returns(true)
		request = mock('request')
    	request.stubs(:url).returns('/test')
		self.stubs(:request).returns(request)
	end

	# Editable Text
	test "should create new editable for new key, and use the existent for existent ones" do
		assert_difference('EditableContent::Editable.count') do
			a = editable_content do
				"test 1"
			end
		end
		assert_difference('EditableContent::Editable.count', 0) do
			editable_content do
				"test 1"
			end
		end
		assert_difference('EditableContent::Editable.count') do
			editable_content('test 2') do
				"test 2"
			end
		end
		assert_difference('EditableContent::Editable.count', 0) do
			editable_content('test 2') do
				"test 2"
			end
		end
	end

	test "should render only text for not allowed users" do
		self.stubs(:can_edit?).returns(false)
		editable = editable_content do
			"text test"
		end
		assert_no_match /data-mercury/, editable
	end

	test "should render editable content to alowed logged users" do
		editable = editable_content do
			"text test"
		end
		assert_match /data-mercury/, editable
	end

	# Editable Images
	test "editable_image_tag without size should raise an error" do
		assert_raises(RuntimeError) { editable_image_tag "rails.png" }
	end

	test "should create new editable image for new key, and use the existent for existent ones" do
		assert_difference('EditableContent::Editable.count') do
			editable_image_tag "test1.png", :size => "50x50"
		end
		assert_difference('EditableContent::Editable.count', 0) do
			editable_image_tag "test1.png", :size => "50x50"
		end
	end

	test "should render only img for not allowed users" do
		self.stubs(:can_edit?).returns(false)
		assert_equal "<img alt=\"Rails\" height=\"50\" src=\"/images/rails.png\" width=\"50\" />", editable_image_tag("rails.png", :size => "50x50")
	end

	test "should render editable image to allowed users" do
		assert_match /data-mercury="image"/, editable_image_tag("rails.png", :size => "50x50")
	end
	
	test "should render editable content with h1 tag" do
		editable = editable_content :h1 do
			"text test"
		end
		assert_match /<h1.*data-mercury.*>/, editable
		editable = editable_content 'text', :h1 do
			"text test"
		end
		assert_match /<h1.*data-mercury.*>/, editable
	end

	test "should render editable content with h1 tag and title class" do
		editable = editable_content :h1, class: "title" do
			"text test"
		end
		assert_match /<h1.*class=\"title\".*data-mercury.*>/, editable
		editable = editable_content 'text', :h1, class: "title" do
			"text test"
		end
		assert_match /<h1.*class=\"title\".*data-mercury.*>/, editable
	end

end