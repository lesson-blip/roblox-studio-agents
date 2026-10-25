--!strict
-- Colours, fonts and sizes for the HUD (spec 7). Reference screen 844 by 390 points.

local Theme = {}

Theme.REF_W = 844
Theme.REF_H = 390

Theme.FONT_HEAD = Enum.Font.FredokaOne
Theme.FONT_BODY = Enum.Font.GothamMedium
Theme.FONT_BOLD = Enum.Font.GothamBold

Theme.TEXT = Color3.fromRGB(255, 255, 255)
Theme.TEXT_DARK = Color3.fromRGB(40, 35, 30)
Theme.PANEL = Color3.fromRGB(38, 50, 40)
Theme.PANEL_LIGHT = Color3.fromRGB(250, 246, 236)
Theme.BUTTON = Color3.fromRGB(60, 140, 80)
Theme.BUTTON_ALT = Color3.fromRGB(90, 90, 90)
Theme.WARN = Color3.fromRGB(200, 70, 60)
Theme.SAP = Color3.fromRGB(240, 190, 60)
Theme.HEART = Color3.fromRGB(230, 80, 90)
Theme.GREY = Color3.fromRGB(120, 120, 120)

Theme.TEXT_MIN = 14
Theme.TEXT_NUMBER = 18
Theme.TOUCH = 48

return Theme
