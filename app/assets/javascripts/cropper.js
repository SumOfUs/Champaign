// Vanilla JavaScript image cropper from http://dev.vizuina.com/cropper/
var Cropper = function() {
    function t(e, t) {
        return e.currentStyle ? e.currentStyle[t] : typeof window.getComputedStyle == "function" ? window.getComputedStyle(e, null).getPropertyValue(t) : e.style[t]
    }

    function r(e) {
        return e = e || window.event, e.target = e.target || e.srcElement, e.relatedTarget = e.relatedTarget || (e.type == "mouseover" ? e.fromElement : e.toElement), e.target = e.target || e.srcElement, e.stop = function() {
            e.preventDefault ? e.preventDefault() : e.returnValue = !1, e.stopPropagation && e.stopPropagation(), e.cancelBubble != null && (e.cancelBubble = !0)
        }, e.target.nodeType === 3 && (e.target = e.target.parentNode), e
    }

    function i(e) {
        if (e === null || typeof e != "object") return e;
        var t = e.constructor();
        for (var n in e) t[n] = i(e[n]);
        return t
    }
    var e = {
        container_class: "cropper",
        width: 0,
        height: 0,
        min_width: 0,
        min_height: 0,
        max_width: 0,
        max_height: 0,
        ratio: {
            width: 0,
            height: 0
        }
    };
    Function.prototype.bind || (Function.prototype.bind = function(e) {
        if (typeof this != "function") throw new TypeError("Bound function not callable");
        var t = Array.prototype.slice.call(arguments, 1),
            n = this,
            r = function() {},
            i = function() {
                return n.apply(this instanceof r && e ? this : e, t.concat(Array.prototype.slice.call(arguments)))
            };
        return r.prototype = this.prototype, i.prototype = new r, i
    });
    var n = function() {
            return window.addEventListener ? function(e, t, n) {
                e.addEventListener(t, n, !1)
            } : window.attachEvent ? function(e, t, n) {
                e.attachEvent("on" + t, n)
            } : function(e, t, n) {
                e["on" + t] = n
            }
        }(),
        s = function(t, n) {
            this.options = i(e), n = n || {};
            for (var r in n) this.options[r] = n[r];
            this.image = t;
            var s = this.image.getBoundingClientRect();
            this.width = Math.round(s.right - s.left), this.height = Math.round(s.bottom - s.top), this.coordinates = {
                x: 0,
                y: 0,
                width: 0,
                height: 0
            }, this.moving = this.resizing = this.direction = !1, this.handles = {}, this.overlays = {}, this.wrapImage(), this.attachEventListeners()
        };
    return s.prototype.wrapImage = function() {
        var e = document.createElement("div");
        e.className = this.options.container_class;
        // e.id = "cropper";
        var n = this.image.parentNode,
            r = this.image.nextSibling;
        e.appendChild(this.image), this.image.style.padding = this.image.style.margin = this.image.style.border = 0, r ? n.insertBefore(e, r) : n.appendChild(e), this.image.ondragstart = function() {
            return !1
        };
        var i = t(e, "position");
        i == "static" && (e.style.position = "relative"), e.style.width = this.width + "px", e.style.height = this.height + "px", this.container = e
    }, s.prototype.createCropArea = function(e) {
        var t = document.createElement("div");
        t.className = this.options.container_class + "-area", t.style.position = "absolute", t.style.cursor = "move", t.style.background = "url(data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7)", this.createHandles(t), this.createOverlays(t), this.container.appendChild(t), this.crop_area = t
    }, s.prototype.createHandles = function(e) {
        var t = this,
            i = "-3px",
            s = {
                nw: {
                    left: i,
                    top: i
                },
                n: {
                    left: "50%",
                    top: i,
                    marginLeft: i
                },
                ne: {
                    right: i,
                    top: i
                },
                e: {
                    right: i,
                    top: "50%",
                    marginTop: i
                },
                se: {
                    right: i,
                    bottom: i,
                    zIndex: 10
                },
                s: {
                    left: "50%",
                    bottom: i,
                    marginLeft: i
                },
                sw: {
                    left: i,
                    bottom: i
                },
                w: {
                    left: i,
                    top: "50%",
                    marginTop: i
                }
            };
        for (var o in s) {
            var u = s[o],
                a = document.createElement("div");
            a.className = this.options.container_class + "-area-handle";
            for (var f in u) a.style[f] = u[f];
            a.style.position = "absolute", a.style.cursor = o + "-resize", a.setAttribute("position", o), e.appendChild(a), n(a, "mousedown", function(e) {
                t.resizing = !0, t.direction = r(e).target.getAttribute("position")
            }), this.handles[o] = a
        }
    }, s.prototype.createOverlays = function() {
        var e = {
            top: {
                left: 0,
                top: 0,
                right: 0,
                width: "100%"
            },
            left: {
                left: 0
            },
            right: {
                right: 0
            },
            bottom: {
                left: 0,
                bottom: 0,
                right: 0,
                width: "100%"
            }
        };
        for (position in e) {
            var t = e[position],
                n = document.createElement("div");
            n.className = this.options.container_class + "-overlay", n.style.position = "absolute";
            for (var r in t) n.style[r] = t[r];
            this.container.appendChild(n), this.overlays[position] = n
        }
    }, s.prototype.attachEventListeners = function() {
        n(this.container, "mousedown", this.mouseDown.bind(this)), n(document, "mouseup", this.mouseUp.bind(this)), n(document, "mousemove", this.mouseMove.bind(this))
    }, s.prototype.mouseDown = function(e) {
        r(e).stop();
        var t = r(e).target,
            n = this.getCursorPosition(e);
        this.crop_area || this.createCropArea(n), this.dragStartCrop = i(this.coordinates), this.dragStart = n;
        if (t == this.crop_area) {
            this.moving = !0;
            return
        }
        if (t.className == this.options.container_class + "-area-handle") return;
        var s = this.options.width ? this.options.width : this.options.min_width ? this.options.min_width : 0,
            o = this.options.height ? this.options.height : this.options.min_height ? this.options.min_height : 0;
        this.coordinates.x = n.x, this.coordinates.y = n.y, this.coordinates.width = s, this.coordinates.height = o, this.dragStartCrop = i(this.coordinates), this.crop();
        if (s && o) return;
        this.resizing = !0, this.direction = "se"
    }, s.prototype.crop = function() {
        this.confine(), this.crop_area.style.left = this.coordinates.x + "px", this.crop_area.style.top = this.coordinates.y + "px", this.crop_area.style.width = this.coordinates.width + "px", this.crop_area.style.height = this.coordinates.height + "px", this.overlays.top.style.height = this.overlays.left.style.top = this.overlays.right.style.top = this.coordinates.y + "px", this.overlays.left.style.height = this.overlays.right.style.height = this.coordinates.height + "px", this.overlays.left.style.width = this.coordinates.x + "px", this.overlays.right.style.width = this.width - this.coordinates.x - this.coordinates.width + "px", this.overlays.bottom.style.height = this.height - this.coordinates.y - this.coordinates.height + "px", typeof this.options.update == "function" && this.options.update.call(this, this.coordinates)
    }, s.prototype.confine = function() {
        this.coordinates.x + this.coordinates.width > this.width && (this.coordinates.x = this.width - this.coordinates.width), this.coordinates.x < 0 && (this.coordinates.x = 0), this.coordinates.y + this.coordinates.height > this.height && (this.coordinates.y = this.height - this.coordinates.height), this.coordinates.y < 0 && (this.coordinates.y = 0)
    }, s.prototype.mouseUp = function(e) {
        this.resizing = this.moving = this.direction = !1
    }, s.prototype.mouseMove = function(e) {
        if (this.resizing) return this.resize(e);
        if (this.moving) return this.move(e)
    }, s.prototype.resize = function(e) {
        function o() {
            this.direction.match(/w/) ? (n = t.x, i -= delta_x, t.x > this.dragStartCrop.x + this.dragStartCrop.width && (this.direction = this.direction.replace("w", "e"), n = this.dragStartCrop.x + this.dragStartCrop.width, this.dragStart.x = this.dragStartCrop.x = n, this.dragStartCrop.width = i = 0)) : this.direction.match(/e/) && (i = Math.min(i + delta_x, this.width - n), t.x < this.dragStartCrop.x && (this.direction = this.direction.replace("e", "w"), this.dragStart.x = n, this.dragStartCrop.width = i = 0))
        }

        function u(e) {
            this.direction.match(/n/) ? (e ? (s = Math.round(i / e), r = this.dragStartCrop.y + this.dragStartCrop.height - s) : (r = t.y, s -= delta_y), t.y > this.dragStartCrop.y + this.dragStartCrop.height && (this.direction = this.direction.replace("n", "s"), r = this.dragStart.y + this.dragStartCrop.height, this.dragStart.y = this.dragStartCrop.y = r, this.dragStartCrop.height = s = 0)) : this.direction.match(/s/) && (e ? s = Math.round(i / e) : s = Math.min(s + delta_y, this.height - r), t.y < this.dragStartCrop.y && (this.direction = this.direction.replace("s", "n"), this.dragStart.y = r, this.dragStartCrop.height = s = 0))
        }
        var t = this.getCursorPosition(e),
            n = this.dragStartCrop.x,
            r = this.dragStartCrop.y,
            i = this.dragStartCrop.width,
            s = this.dragStartCrop.height;
        t.x = Math.max(0, t.x), t.y = Math.max(0, t.y), delta_x = t.x - this.dragStart.x, delta_y = t.y - this.dragStart.y;
        if (this.options.ratio.width > 0 && this.options.ratio.height > 0) {
            var a = this.options.ratio.width / this.options.ratio.height;
            this.direction == "n" || this.direction == "s" ? (u.call(this), i = s * a) : this.direction == "w" || this.direction == "e" ? (o.call(this), s = i / a) : (o.call(this), u.call(this, a))
        } else o.call(this), u.call(this);
        this.options.min_width && (i = Math.max(i, this.options.min_width)), this.options.min_height && (s = Math.max(s, this.options.min_height)), this.options.max_width && (i = Math.min(i, this.options.max_width)), this.options.max_height && (s = Math.min(s, this.options.max_height)), this.coordinates.x = Math.round(n), this.coordinates.y = Math.round(r), this.coordinates.width = Math.round(i), this.coordinates.height = Math.round(s), this.crop()
    }, s.prototype.move = function(e) {
        var t = this.getCursorPosition(e),
            n = t.x - this.dragStart.x,
            r = t.y - this.dragStart.y;
        this.coordinates.x = this.dragStartCrop.x + n, this.coordinates.y = this.dragStartCrop.y + r, this.crop()
    }, s.prototype.getCursorPosition = function(e) {
        var t = this.container.getBoundingClientRect();
        return e = r(e), {
            x: Math.round(e.clientX - t.left),
            y: Math.round(e.clientY - t.top)
        }
    }, s
}();