# encoding: utf-8
from __future__ import division, print_function, unicode_literals

import math
import objc
from AppKit import NSFont, NSMakeRect, NSTextField, NSView
from Foundation import NSPoint
from GlyphsApp import Glyphs, GSCustomParameter
from GlyphsApp.plugins import FilterWithDialog

GSSteppingTextField = objc.lookUpClass('GSSteppingTextField')


class PixelSlanter(FilterWithDialog):

	@objc.python_method
	def settings(self):
		self.menuName = Glyphs.localize({'en': 'Pixel Slanter'})
		self.actionButtonLabel = Glyphs.localize({'en': 'Slant'})

		# Build dialog view programmatically
		width = 190
		height = 40
		view = NSView.alloc().initWithFrame_(NSMakeRect(0, 0, width, height))

		# "Angle:" label
		label = NSTextField.labelWithString_("Angle:")
		label.setFont_(NSFont.systemFontOfSize_(NSFont.smallSystemFontSize()))
		label.setFrame_(NSMakeRect(10, 12, 50, 18))
		view.addSubview_(label)

		# Angle input with stepping
		self.angleField = GSSteppingTextField.alloc().initWithFrame_(NSMakeRect(65, 8, 70, 22))
		self.angleField.setStringValue_("8")
		view.addSubview_(self.angleField)

		# "°" suffix label
		degreeLabel = NSTextField.labelWithString_("°")
		degreeLabel.setFont_(NSFont.systemFontOfSize_(NSFont.smallSystemFontSize()))
		degreeLabel.setFrame_(NSMakeRect(140, 12, 20, 18))
		view.addSubview_(degreeLabel)

		self.dialog = view

	@objc.python_method
	def start(self):
		Glyphs.registerDefault('com.mekkablue.PixelSlanter.angle', 8.0)
		savedAngle = Glyphs.defaults.get('com.mekkablue.PixelSlanter.angle', 8.0)
		self.angleField.setStringValue_(str(savedAngle))

	@objc.python_method
	def filter(self, layer, inEditView, customParameters):
		# Resolve angle value
		if customParameters and 'angle' in customParameters:
			angle = float(customParameters['angle'])
		else:
			try:
				angle = float(self.angleField.stringValue())
			except Exception:
				angle = 8.0
			Glyphs.defaults['com.mekkablue.PixelSlanter.angle'] = angle

		if angle == 0.0 or not layer.components:
			return

		tanAngle = math.tan(math.radians(angle))

		# Determine pivot Y from master; fall back to 0 (baseline)
		pivot = layer.master.slantHeightForLayer_(layer) or 0

		for component in layer.components:
			y = component.position.y
			component.x = round(component.position.x + (y - pivot) * tanAngle)

	@objc.python_method
	def generateCustomParameter(self):
		return GSCustomParameter(
			name=self.__class__.__name__,
			value={'angle': self.angleField.floatValue()},
		)

	@objc.python_method
	def __file__(self):
		return __file__
