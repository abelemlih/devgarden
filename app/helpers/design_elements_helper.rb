require "svg_path"

module DesignElementsHelper

  def theme_style(model, role)
    hue = configured_hue(model) || default_hue(model)
    saturation = 45
    lightness = circular_interpolate(LIGHTNESS_BY_HUE, hue / 360.0 * LIGHTNESS_BY_HUE.length)

    case role
      when :featured_text
      when :body_text
        lightness /= 1.5
      when :background
        saturation -= 5
      when :button_background
        saturation += 30
      else
        raise "Unknown feature color role: #{role.inspect}"
    end

    color = "hsl(#{hue}, #{saturation}%, #{lightness}%)"

    case role
      when :featured_text,
           :body_text
        "color: #{color}"
      when :background,
           :button_background
        "background: #{color}"
    end
  end

  def project_divider_path(npts = 2)
    path = SVGPath.new

    def randsign
      rand(2) * 2 - 1
    end

    x0, y0 = 0, rand(-0.5..0.5)
    x1, y1 = rand(0.1..0.5), 1 * randsign
    x2, y2 = rand(0.5..0.9), 1 * randsign
    x3, y3 = 1, rand(-0.5..0.5)
    ally = [y0, y1, y2, y3]
    ymid = (ally.min + ally.max) / 2

    thickness = 0.1

    path.move_to(x0, y0 - ymid)
    path.cubic_to(
      x1, y1 + thickness - ymid,
      x2, y2 + thickness - ymid,
      x3, y3 - ymid)
    path.cubic_to(
      x2, y2 - thickness - ymid,
      x1, y1 - thickness - ymid,
      x0, y0 - ymid)
    path.close

    path.to_s
  end

private

  LIGHTNESS_BY_HUE = [38, 34, 25, 32, 45, 36]
  GOLDEN_ANGLE = 180 * (3 - Math.sqrt(5))

  def configured_hue(model)
    model.theme_hue if model.respond_to?(:theme_hue)
  end

  def default_hue(model)
    model.id * GOLDEN_ANGLE % 360
  end

  def circular_interpolate(array, index)
    w = index % 1
    array[index] * (1-w) + array[(index + 1) % array.length] * w
  end

end
