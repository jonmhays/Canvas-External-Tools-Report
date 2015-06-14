#!/usr/bin/ruby
# encoding: UTF-8

require 'rubygems'
require 'yaml'
require 'httparty'
require 'csv'
require 'json'

# Get Course Nav for a list of courses from the Canvas-LMS
class Find_Course_Nav
  include HTTParty
  # debug_output

  def initialize
    @config = YAML.load_file('config.yml')
    @host = @config['host']
    @auth_token = @config['admin_token']
    @headers = {'Authorization' => "Bearer #{@auth_token}", 'Content-Type' => 'application/json'}
  end

  def filter(hsh, *keys)
    hsh.dup.tap do |h|
      keys.each { |k| h.delete(k) }
    end
  end

# iterate through canvas tabs api
  def list_course_nav(canvas_course_id)
    options = {
      :headers => @headers
    }

    course_nav_path = "#{@host}/api/v1/courses/#{canvas_course_id}/tabs"
    course_nav_result = self.class.get(course_nav_path, options)

# adding the course id to a hash with unused and hidden since they don't always exist in the feed
    h1 = {"canvas_course_id" => "#{canvas_course_id}","id" => "","unused" => "", "hidden" => ""}

# only keeping tabs that are external tools
    course_nav_result.delete_if do |nav_list|
      nav_list["type"] == "internal"
    end

# merging my custom hash with the canvas feed
    course_nav_result.each do |nav_list|
      h1.merge!(nav_list)
      nav_list.replace(h1)
    end
    list_course_nav = course_nav_result
    list_course_nav
  end

# loading course ids from a standard canvas report
  def load_canvas_course_ids
    @courses = []
    CSV.foreach('reports/' + @config['courses_csv'], :headers => :first_row) do |course|
      @courses << {'canvas_course_id' => course['canvas_course_id']}
    end
    puts "Courses Loaded from CSV for processing: #{@courses.inspect}\n\n\n"
    @courses
  end

# Specifying the Headers since I'm using some merge hash trickery to make sure hidden and unused columns are included
  def course_nav_report_file
    headers = [
      'canvas_course_id',
      'id',
      'unused',
      'hidden',
      'html_url',
      'full_url',
      'position',
      'visibility',
      'label',
      'type',
      'launch_url'
    ]

    @course_nav_report_file = CSV.open('reports/' + @config['report_filename'], 'wb', { :headers => headers, :write_headers => true})
  end

# This is the Canvas Nav Report that looks for external tool placements
  def course_nav_report
    load_canvas_course_ids
    report_file = course_nav_report_file
    @courses.each_with_index do |course, index|
      puts course['canvas_course_id']
      course_nav = list_course_nav(course['canvas_course_id'])
      course_nav.each do |course_nav_list|
        report_file << course_nav_list.values
      end
    end
    puts "---------------------------"
    puts "Report Generation Completed"
    puts "---------------------------"
  end
end

proxy = Find_Course_Nav.new
proxy.course_nav_report

