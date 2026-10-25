import 'dart:async';
import 'dart:js_interop';

import 'package:nmail_core/widgets/keeps_text_field_focus.dart';
import 'package:web/web.dart' as web;

/// Flutter web types into the DOM field of the focused semantics text field,
/// and stops when the browser takes the focus from it.
void keepSemanticsTextFieldFocus() {
  web.EventStreamProviders.mouseDownEvent
      .forTarget(web.document, useCapture: true)
      .listen(_keepFocusOnMouseDown);
  web.EventStreamProviders.clickEvent
      .forTarget(web.window, useCapture: true)
      .listen(_keepFocusOnClick);
  for (final type in ['blur', 'focusout', 'focus', 'focusin']) {
    web.EventStreamProvider<web.FocusEvent>(
      type,
    ).forTarget(web.window, useCapture: true).listen(_guardFocusEvent);
  }
}

/// The field a click keeps the focus on, until the click is handled.
web.HTMLElement? _clickKeptField;

/// The browser would move the focus to the Flutter view. The framework moves
/// it itself when the field loses it.
void _keepFocusOnMouseDown(web.MouseEvent event) {
  if (_activeSemanticsTextField() == null) return;
  final target = event.target;
  if (target == null || !target.isA<web.Element>()) return;
  final element = target as web.Element;
  if (_isSemanticsTextField(element)) return;
  if (element.closest('flt-semantics') != null) event.preventDefault();
}

/// The engine takes a click with integer coordinates, which every mouse click
/// in Chrome has, for an assistive technology's, and gives the clicked button
/// the focus.
void _keepFocusOnClick(web.MouseEvent event) {
  final field = _activeSemanticsTextField();
  if (field == null || !_keepsTextFieldFocus(event.target)) return;
  _clickKeptField = field;
  // After the whole dispatch: a microtask would run before the engine's
  // listener.
  Timer.run(() {
    _clickKeptField = null;
    if (field.isConnected &&
        !field.strictEquals(web.document.activeElement).toDart) {
      field.focus(web.FocusOptions(preventScroll: true));
    }
  });
}

void _guardFocusEvent(web.FocusEvent event) {
  final target = event.target;
  if (target == null || !target.isA<web.HTMLElement>()) return;
  final element = target as web.HTMLElement;
  final isLoss = event.type == 'blur' || event.type == 'focusout';
  final kept = _clickKeptField;
  if (kept != null) {
    if (element.strictEquals(kept).toDart == isLoss) {
      event.stopImmediatePropagation();
    }
    return;
  }
  if (isLoss) _restoreFocusAfterMove(event, element);
}

/// The engine moves the field in the DOM when a node is inserted above it, as
/// a tooltip showing does, and the browser blurs it with no next target. The
/// engine would then take the focus from the framework.
void _restoreFocusAfterMove(web.FocusEvent event, web.HTMLElement field) {
  if (!_isSemanticsTextField(field)) return;
  if (event.relatedTarget != null ||
      !web.document.hasFocus() ||
      !field.isConnected) {
    return;
  }
  event.stopImmediatePropagation();
  scheduleMicrotask(() {
    final active = web.document.activeElement;
    if (field.isConnected &&
        (active == null || active.strictEquals(web.document.body).toDart)) {
      field.focus(web.FocusOptions(preventScroll: true));
    }
  });
}

web.HTMLElement? _activeSemanticsTextField() {
  final active = web.document.activeElement;
  if (active == null || !_isSemanticsTextField(active)) return null;
  return active as web.HTMLElement;
}

bool _keepsTextFieldFocus(web.EventTarget? target) {
  if (target == null || !target.isA<web.Element>()) return false;
  const id = KeepsTextFieldFocus.semanticsIdentifier;
  return (target as web.Element).closest('[flt-semantics-identifier="$id"]') !=
      null;
}

bool _isSemanticsTextField(web.Element element) =>
    element.getAttribute('data-semantics-role') == 'text-field';
