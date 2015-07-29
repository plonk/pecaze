require 'gtk2'
include Gtk

class ClockRenderer
  include Math

  LOGO = 'Pecazen'

  DIGIT_DISTANCE = 0.3

  SEC_HAND_LENGTH = 0.30
  SEC_HAND_WIDTH = 0.005

  MIN_HAND_LENGTH = 0.30
  MIN_HAND_WIDTH = 0.02

  HOUR_HAND_LENGTH = 0.2
  HOUR_HAND_WIDTH = 0.03

  STRAIGHT_UP_RADIAN = -1 / 4.0 * 2 * PI

  def initialize
    @ring_color = 3.times.map { 0.75 + rand / 2.0 }
    @sec_hand_color = 3.times.map { 0.75 + rand / 2.0 }
    @min_hand_color = 3.times.map { 0.75 + rand / 2.0 }
    @hour_hand_color = 3.times.map { 0.75 + rand / 2.0 }
    @text_color = 3.times.map { rand / 2.0 }

    @sec, @min, @hour = [0, 0, 0]
  end

  def time=(time_obj)
    @sec = time_obj.sec + time_obj.subsec.to_f
    @min = time_obj.min
    @hour = time_obj.hour
  end

  def draw_bg(cr)
    cr.set_source_rgb(*[0.5] * 3)
    cr.rectangle(0, 0, 1, 1)
    cr.fill
  end

  def draw_circum(cr)
    cr.move_to(0.5 + 0.375, 0.5)
    cr.set_line_width 0.02
    cr.set_source_rgb(*@ring_color)
    cr.circle(0.5, 0.5, 0.375)
    cr.stroke
  end

  def draw_logo(cr)
    cr.select_font_face('Georgia',
                        Cairo::FONT_SLANT_NORMAL,
                        Cairo::FONT_WEIGHT_BOLD)
    cr.set_font_size(0.055)
    cr.set_source_rgb(*@text_color)
    te = cr.text_extents(LOGO)
    cr.move_to(0.5 - te.width / 2 - te.x_bearing,
               0.55 - te.height / 2 - te.y_bearing)
    cr.show_text(LOGO)
  end

  def draw_digits(cr)
    cr.select_font_face('Georgia',
                        Cairo::FONT_SLANT_NORMAL,
                        Cairo::FONT_WEIGHT_BOLD)
    cr.set_font_size(0.1)
    cr.set_source_rgb(*@text_color)

    (0..11).each do |i|
      text = i == 0 ? '12' : i.to_s
      draw_digit(cr, text, to_radian(i % 12, 12))
    end
  end

  def draw_digit(cr, text, radian)
    te = cr.text_extents(text)
    xoff = te.width / 2 + te.x_bearing
    yoff = te.height / 2 + te.y_bearing
    cr.move_to(0.5 + DIGIT_DISTANCE * cos(radian) - xoff,
               0.5 + DIGIT_DISTANCE * sin(radian) - yoff)
    cr.show_text(text)
  end

  def hour_to_radian
    to_radian((@hour % 12) + (@min / 60.0), 12)
  end

  def to_radian(value, unit)
    STRAIGHT_UP_RADIAN + value / unit.to_f * 2 * PI
  end

  OPPOSITE_LENGTH = 0.025

  def draw_hand(cr, width, length, dir, color)
    cr.set_line_width width
    cr.set_source_rgb(*color)
    cr.move_to(0.5, 0.5)
    cr.rel_line_to(OPPOSITE_LENGTH * cos(dir + 1*PI), OPPOSITE_LENGTH * sin(dir + 1*PI))
    cr.move_to(0.5, 0.5)
    cr.rel_line_to(length * cos(dir), length * sin(dir))
    cr.stroke
  end

  def draw_sec_hand(cr)
    draw_hand(cr, SEC_HAND_WIDTH, SEC_HAND_LENGTH,
              to_radian(@sec, 60), @sec_hand_color)
  end

  def draw_min_hand(cr)
    draw_hand(cr, MIN_HAND_WIDTH, MIN_HAND_LENGTH,
              to_radian(@min, 60), @min_hand_color)
  end

  def draw_hour_hand(cr)
    draw_hand(cr, HOUR_HAND_WIDTH, HOUR_HAND_LENGTH,
              hour_to_radian, @hour_hand_color)
  end

  def draw(cr)
    draw_bg(cr)

    draw_circum(cr)
    draw_digits(cr)
    draw_logo(cr)

    draw_sec_hand(cr)
    draw_min_hand(cr)
    draw_hour_hand(cr)
  end
end
