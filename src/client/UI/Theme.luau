--!strict
-- Colours, fonts and sizes for the HUD (spec 7), matched to the preview HUD
-- (design/preview3d/index.html): dark rounded pills with a near black outline and a
-- drop edge, white Fredoka numbers with a dark stroke. Reference screen 844 by 390.

local Theme = {}

Theme.REF_W = 844
Theme.REF_H = 390

Theme.FONT_HEAD = Enum.Font.FredokaOne
Theme.FONT_BODY = Enum.Font.GothamMedium
Theme.FONT_BOLD = Enum.Font.GothamBold

Theme.TEXT = Color3.fromRGB(255, 255, 255)
Theme.TEXT_DARK = Color3.fromRGB(44, 38, 51) -- #2c2633
Theme.INK = Color3.fromRGB(20, 18, 26) -- #14121a, outlines and drop edges
Theme.TEXT_STROKE = Color3.fromRGB(35, 32, 43) -- #23202b
Theme.PILL_TOP = Color3.fromRGB(58, 54, 70) -- #3a3646
Theme.PILL_BOTTOM = Color3.fromRGB(36, 33, 45) -- #24212d
Theme.PANEL = Color3.fromRGB(36, 33, 45)
Theme.PANEL_LIGHT = Color3.fromRGB(255, 250, 240) -- #fffaf0, Nan's bubble
Theme.BUTTON = Color3.fromRGB(79, 174, 60)
Theme.BUTTON_TOP = Color3.fromRGB(155, 227, 106)
Theme.SPEED_TOP = Color3.fromRGB(111, 208, 255) -- #6fd0ff
Theme.SPEED_BOTTOM = Color3.fromRGB(47, 155, 224) -- #2f9be0
Theme.MENU_TOP = Color3.fromRGB(90, 85, 104) -- #5a5568
Theme.BUTTON_ALT = Color3.fromRGB(90, 85, 104)
Theme.WARN = Color3.fromRGB(222, 74, 99)
Theme.SAP = Color3.fromRGB(255, 194, 58) -- #ffc23a
Theme.SAP_TOP = Color3.fromRGB(255, 215, 94) -- #ffd75e
Theme.SAP_BOTTOM = Color3.fromRGB(242, 165, 40) -- #f2a528
Theme.HEART = Color3.fromRGB(255, 77, 94) -- #ff4d5e
Theme.GREY = Color3.fromRGB(150, 146, 158)
Theme.NAN_NAME = Color3.fromRGB(107, 93, 122) -- #6b5d7a
Theme.NAN_HIGHLIGHT = Color3.fromRGB(194, 65, 12) -- #c2410c
Theme.SAP_FLOAT = Color3.fromRGB(184, 245, 90) -- #b8f55a

Theme.TEXT_MIN = 14
Theme.TEXT_NUMBER = 18
Theme.TOUCH = 44
Theme.RADIUS = 12

return Theme
