# -*- coding: undecided -*-
require 'gtk2'
require_relative 'clock_renderer'
include Gtk

class MainWindow < Gtk::Window
  def initialize
    super

    set_title 'Clock'

    # destroy されてからでは遅いので delete でタイマーを停止する。
    signal_connect 'delete-event' do
      Gtk.timeout_remove @timer
      false
    end
    signal_connect 'destroy' do
      Gtk.main_quit
    end

    init_ui

    @timer = Gtk.timeout_add 33 do
      @clock_renderer.time = Time.now
      invalidate
    end

    set_default_size 380, 380
    set_window_position :center
    show_all
  end

  def invalidate
    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end


  def forget_key_state
    @keybits.clear
  end

  def init_ui
    @clock_renderer = ClockRenderer.new

    signal_connect('expose-event') do
      redraw
      true
    end
    @old_size = size
    signal_connect('configure-event') do |_, e|
      if [e.width, e.height] != @old_size
        redraw
        @old_size = size
      end
      true
    end
  end

  def redraw
    cr = window.create_cairo_context
    w, h = size
    cr.scale(w,h)
    @clock_renderer.draw(cr)
    cr.destroy
  end
end

app = MainWindow.new
Gtk.main
