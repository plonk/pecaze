# -*- coding: utf-8 -*-
require 'gtk2'
require_relative 'clock_renderer'
include Gtk

class MainWindow < Gtk::Window
  attr_reader :finished

  def initialize
    super

    @finished = false

    init_ui

    @clock_renderer = ClockRenderer.new

    @old_size = size
    connect_callbacks
  end

  def connect_callbacks
    signal_connect 'destroy' do
      @finished = true
    end

    signal_connect('expose-event') do
      redraw
      true
    end

    signal_connect('configure-event') do |_, e|
      if [e.width, e.height] != @old_size
        redraw
        @old_size = size
      end
      true
    end
  end

  def invalidate
    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end

  def init_self
    set_default_size 380, 380
    set_window_position :center
    set_title 'Clock'
  end

  def init_ui
    init_self
  end

  def redraw
    cr = window.create_cairo_context
    cr.scale(*size)
    @clock_renderer.draw(cr)
    cr.destroy
  end

  def update
    @clock_renderer.time = Time.now
  end

  def draw
    invalidate
  end
end

MS_PER_UPDATE = 1 / 60.0

def main_loop(app)
  previous = Time.now
  lag = 0.0
  dirty = false

  loop do
    Gtk.main_iteration if Gtk.events_pending?
    break if app.finished

    current = Time.now
    lag += current - previous
    previous = current

    while lag >= MS_PER_UPDATE
      app.update
      dirty = true
      lag -= MS_PER_UPDATE
    end

    if dirty
      app.draw
      dirty = false
    else
      sleep(MS_PER_UPDATE / 3.0)
      next
    end
  end
end

main_loop MainWindow.new.show_all
