// 用 translate 取代 relative
window.SwitchUtils = {};

SwitchUtils.animating = false;

SwitchUtils.switch_anything = function ($ele, $target, options) {
  if (this.animating) {
    return;
  }

  var direction;

  if ($.inArray($target[0], $ele.prevAll().toArray()) >= 0) {
    direction = "up";
    $.merge($target, $ele.prevAll().filter($target.nextAll()));
  } else if ($.inArray($target[0], $ele.nextAll().toArray()) >= 0) {
    direction = "down";
    $.merge($target, $ele.nextAll().filter($target.prevAll()));
  }

  if (!direction) {
    return;
  }

  this.animating = true;

  var steps = 15,
      current_step = 0,
      target_move_distance = direction == "up" ? ($target.offset().top - $ele.offset().top) : ($target.offset().top + $target.outerHeight() - ($ele.offset().top + $ele.outerHeight())),
      prev_move_distance = direction == "up" ? $ele.outerHeight() : - $ele.outerHeight();

  var animation = function () {
    if (current_step < steps) {
      $ele.css({top: target_move_distance * current_step / steps });
      $target.css({top: prev_move_distance * current_step / steps})
      current_step += 1;
      // can be ppt
      // setTimeout(function(){requestAnimationFrame(animation)}, 200)
      requestAnimationFrame(animation);
    } else {
      $ele.css({top: 0});
      $target.css({top: 0});
      if (direction == "up") {
        $ele.insertBefore($target[0]);
      } else {
        $ele.insertAfter($target[0]);
      }
      this.animating = false;
    }
  }.bind(this);

  animation();
}