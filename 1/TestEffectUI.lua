TestEffectUI = {}
_G.TestEffectUI = TestEffectUI
require "jsonUtil"
local _gt = UILayout.NewGUIDUtilTable()

Data = {
    {   --SetUIEffect
        EffectType = "Effect",
        GetFun = GUI.GetUIEffect,
        AddFun = GUI.AddUIEffect,
        RemoveFun = GUI.RemoveUIEffect,
        Items = {
            --[[/**设置视觉效果插件参数
        *@param EffectMode 效果因子Range(0, 1)
        *@param EffectFactor 溶解区域宽度[Range(0, 1)]
        *@param ColorMode 颜色叠加模式ColorMode.Multiply,ColorMode.Fill,ColorMode.Add,ColorMode.Subtract
        *@param ColorFactor 颜色叠加因子
        *@param BlurMode 模糊模式BlurMode.None, BlurMode.FastBlur, BlurMode.MediumBlur, BlurMode.DetailBlur
        *@param BlurFactor 模糊因子
        *@param AdvancedBlur Advanced blurring remove common artifacts in the blur effect for uGUI
        */]] --

            {
                Type = "Enum",
                Name = "EffectMode",
                Enum = {
                    {UIEffects.EffectMode.None, "None"},
                    {UIEffects.EffectMode.Grayscale, "Grayscale"},
                    {UIEffects.EffectMode.Sepia, "Sepia"},
                    {UIEffects.EffectMode.Nega, "Nega"},
                    {UIEffects.EffectMode.Pixel, "Pixel"}
                },
                GetFun = GUI.EffectGetEffectMode,
                SetFun = GUI.EffectSetEffectMode
            }, {
                Type = "Float",
                Name = "EffectFactor",
                SetFun = GUI.EffectSetEffectFactor,
                GetFun = GUI.EffectGetEffectFactor,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 1
            }, {
                Type = "Enum",
                Name = "ColorMode",
                Enum = {
                    {UIEffects.ColorMode.Multiply, "Multiply"},
                    {UIEffects.ColorMode.Fill, "Fill"},
                    {UIEffects.ColorMode.Add, "Add"},
                    {UIEffects.ColorMode.Subtract, "Subtract"}
                },
                GetFun = GUI.EffectGetColorMode,
                SetFun = GUI.EffectSetColorMode
            }, {
                Type = "Float",
                Name = "ColorFactor",
                GetFun = GUI.EffectGetColorFactor,
                SetFun = GUI.EffectSetColorFactor,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 1
            }, {
                Type = "Enum",
                Name = "BlurMode",
                Enum = {
                    {UIEffects.BlurMode.None, "None"},
                    {UIEffects.BlurMode.FastBlur, "FastBlur"},
                    {UIEffects.BlurMode.MediumBlur, "MediumBlur"},
                    {UIEffects.BlurMode.DetailBlur, "DetailBlur"}
                },
                GetFun = GUI.EffectGetBlurMode,
                SetFun = GUI.EffectSetBlurMode
            }, {
                Type = "Float",
                Name = "BlurFactor",
                GetFun = GUI.EffectGetBlurFactor,
                SetFun = GUI.EffectSetBlurFactor,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 1
            }, {
                Type = "Bool",
                Name = "AdvancedBlur",
                GetFun = GUI.EffectGetAdvancedBlur,
                SetFun = GUI.EffectSetAdvancedBlur,
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}}
            }
        }
    }, {    --SetUIFlip
        EffectType = "Flip",
        GetFun = GUI.GetUIFlip,
        AddFun = GUI.AddUIFlip,
        RemoveFun = GUI.RemoveUIFlip,
        Items = {
            --[[/**设置翻转插件参数
          *@param Horizontal Horizontal翻转
          *@param Veritical Veritical翻转
          */]] --
            {
                Type = "Bool",
                Name = "Horizontal",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                GetFun = GUI.FlipGetHorizontal,
                SetFun = GUI.FlipSetHorizontal
            }, {
                Type = "Bool",
                Name = "Veritical",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                GetFun = GUI.FlipGetVeritical,
                SetFun = GUI.FlipSetVeritical
            }
        }
    }, {
        EffectType = "Gradient",
        GetFun = GUI.GetUIGradient,
        AddFun = GUI.AddUIGradient,
        RemoveFun = GUI.RemoveUIGradient,
        Items = {
            -- Gradient比较特殊, 只有这三种设置的方法, 没有单独的get和set
            -- GradientHorizontal( UIGradientComponent obj  ,  UnityEngine.Color left, UnityEngine.Color left, float offset )
            -- GradientVertical( UIGradientComponent obj  ,  UnityEngine.Color top, UnityEngine.Color bottom, float offset )
            -- GradientAngle( UIGradientComponent obj  ,  UnityEngine.Color color1, UnityEngine.Color color2, float offset, float rotation )
            -- GradientDiagonal( UIGradientComponent obj  ,  UnityEngine.Color color1, UnityEngine.Color color2, UnityEngine.Color color3, UnityEngine.Color color4, float offset1, float offset2, float rotation )
            {
                -- *@param TargetColor 目标颜色
                Type = "Color1",
                Name = "Horizontal",
                StartValue = 0,
                RangeMin = -1,
                RangeMax = 1,
                SetFun = GUI.GradientHorizontal
--
            },
--
            --{
            --    -- *@param TargetColor 目标颜色
            --    Type = "Color1",
            --    Name = "Vertical",
            --    StartValue = 0,
            --    RangeMin = 0,
            --    RangeMax = 1,
            --    SetFun = GUI.GradientVertical
            --},
            --{
            --    -- *@param TargetColor 目标颜色
            --    Type = "Color2",
            --    Name = "Angle",
            --    SetFun = GUI.GradientAngle
            --},
            --{
            --    -- *@param TargetColor 目标颜色
            --    Type = "Color3",
            --    Name = "Diagonal",
            --    SetFun = GUI.GradientDiagonal
            --},

        }
    }, {    --SetUIHsvModifier
        EffectType = "HsvModifier",
        GetFun = GUI.GetUIHsvModifier,
        AddFun = GUI.AddUIHsvModifier,
        RemoveFun = GUI.RemoveUIHsvModifier,
        Items = {
            --[[/**设置HSV图像效果插件参数
          *@param TargetColor 目标颜色
          *@param Range 目标颜色范围[0 ~ 1]
          *@param Hue 色相 [-0.5 ~ 0.5]
          *@param Saturation 饱和度 [-0.5 ~ 0.5]
          *@param Value 色调 [-0.5 ~ 0.5]
          */]] --
            {
                -- *@param TargetColor 目标颜色
                Type = "Color",
                Name = "TargetColor",
                GetFun = GUI.HsvGetTargetColor,
                SetFun = GUI.HsvSetTargetColor
            }, {
                -- *@param Range 目标颜色范围[0 ~ 1]
                Type = "Float",
                Name = "Range",
                GetFun = GUI.HsvGetRange,
                SetFun = GUI.HsvSetRange,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 1
            }, {
                -- *@param Hue 色相 [-0.5 ~ 0.5]
                Type = "Float",
                Name = "Hue",
                GetFun = GUI.HsvGetHue,
                SetFun = GUI.HsvSetHue,
                StartValue = 0,
                RangeMin = -0.5,
                RangeMax = 0.5
            }, {
                --  *@param Saturation 饱和度 [-0.5 ~ 0.5]
                Type = "Float",
                Name = "Saturation",
                GetFun = GUI.HsvGetSaturation,
                SetFun = GUI.HsvSetSaturation,
                StartValue = 0,
                RangeMin = -0.5,
                RangeMax = 0.5
            }, {
                --  *@param Value 色调 [-0.5 ~ 0.5]
                Type = "Float",
                Name = "Value",
                GetFun = GUI.HsvGetValue,
                SetFun = GUI.HsvSetValue,
                StartValue = 0,
                RangeMin = -0.5,
                RangeMax = 0.5
            }
        }

    }, {    --SetUIShiny
        EffectType = "Shiny",
        --[[/**设置闪烁效果插件参数 一下方法均有set,get, EffectFactor会在play时变化
          *@param EffectFactor 效果因子Range(0, 1), 在播放时会变化
          *@param Width 闪烁区域宽度[Range(0, 1)]
          *@param Rotation 闪烁区域旋转
          *@param Softness 闪烁区域柔软度[Range(0, 1)]
          *@param Brightness 闪烁区域亮度[Range(0, 1)]
          *@param Gloss 闪烁区域光泽[Range(0, 1)]
          *@param EffectArea 效果区域模式 EffectArea.RectTransform,EffectArea.Fit,EffectArea.Character
          *@param IsPlay 是否播放
          *@param Duraion 播放持续时间(秒)
          *@param InitalPlayDelay 初始播放演出
          *@param Loop 是否循环
          *@param LoopDelay 循环间隔(秒)
          *@param UpdateMode 更新模式AnimatorUpdateMode.Norma,AnimatorUpdateMode.AnimatePhysics,AnimatorUpdateMode.UnscaledTime
          */
          -- 还有方法GUI.ShinyPlay( UIShinyComponent obj  ,  bool reset = false  )
          -- 还有方法GUI.ShinyStop( UIShinyComponent obj  ,  bool reset = false  )
          ]] --

        GetFun = GUI.GetUIShiny,
        AddFun = GUI.AddUIShiny,
        RemoveFun = GUI.RemoveUIShiny,
        Items = {
            {
              Type = "Float",
              Name = "ShinyEffectFactor",
              SetFun = GUI.ShinySetEffectFactor,
              GetFun = GUI.ShinyGetEffectFactor,
              StartValue = 0.5,
              RangeMin = 0,
              RangeMax = 1
            },
            {
              Type = "Float",
              Name = "ShinyWidth",
              SetFun = GUI.ShinySetWidth,
              GetFun = GUI.ShinyGetWidth,
              StartValue = 0.25,
              RangeMin = 0,
              RangeMax = 1
            },
            {
                Type = "Float",
                Name = "ShinyRotation",
                SetFun = GUI.ShinySetRotation,
                GetFun = GUI.ShinyGetRotation,
                StartValue = 0,
                RangeMin = -180,
                RangeMax = 180
            },
            {
                Type = "Float",
                Name = "ShinySoftness",
                SetFun = GUI.ShinySetSoftness,
                GetFun = GUI.ShinyGetSoftness,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 1
            },
            {
                Type = "Float",
                Name = "ShinyBrightness",
                SetFun = GUI.ShinySetBrightness,
                GetFun = GUI.ShinyGetBrightness,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 1
            },
            {
                Type = "Float",
                Name = "ShinyGloss",
                SetFun = GUI.ShinySetGloss,
                GetFun = GUI.ShinyGetGloss,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 1
            },
            {
                Type = "Float",
                Name = "ShinyDuration",
                SetFun = GUI.ShinySetDuration,
                GetFun = GUI.ShinyGetDuration,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 10
            },
            {
                Type = "Float",
                Name = "ShinyLoopDelay",
                SetFun = GUI.ShinySetLoopDelay,
                GetFun = GUI.ShinyGetLoopDelay,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 10
            },
            {
                Type = "Bool",
                Name = "ShinyLoop",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                GetFun = GUI.ShinyGetLoop,
                SetFun = GUI.ShinySetLoop
            },
            {
              Type = "Bool",
              Name = "ShinyIsPlay",
              StartValue = false,
              Enum = {{false, "false"}, {true, "true"}},
              GetFun = GUI.ShinyGetIsPlay,
              SetFun = GUI.ShinySetIsPlay
            },


        }
    }, {
        EffectType = "Transition",
        --[[/**设置过渡效果插件参数
          *@param EffectMode UITransitionEffect.EffectMode.Fade, UITransitionEffect.EffectMode.Cutoff, UITransitionEffect.EffectMode.Dissolve
          *@param EffectFactor 效果因子Range(0, 1), 在播放时会变化
          *@param Width 闪烁区域宽度[Range(0, 1)]
          *@param Rotation 闪烁区域旋转
          *@param Softness 闪烁区域柔软度[Range(0, 1)]
          *@param Brightness 闪烁区域亮度[Range(0, 1)]
          *@param Gloss 闪烁区域光泽[Range(0, 1)]
          *@param EffectArea 效果区域模式 EffectArea.RectTransform,EffectArea.Fit,EffectArea.Character
          *@param IsPlay 是否播放
          *@param Duraion 播放持续时间(秒)
          *@param InitalPlayDelay 初始播放演出
          *@param Loop 是否循环
          *@param LoopDelay 循环间隔(秒)
          *@param UpdateMode 更新模式AnimatorUpdateMode.Norma,AnimatorUpdateMode.AnimatePhysics,AnimatorUpdateMode.UnscaledTime
          */
          -- 还有方法GUI.TransitionPlay( UITransitionEffectComponent obj  ,  bool reset = false  )
          -- 还有方法GUI.TransitionStop( UITransitionEffectComponent obj  ,  bool reset = false  )
          ]] --
          GetFun = GUI.GetUITransitionEffect,
          AddFun = GUI.AddUITransitionEffect,
          RemoveFun = GUI.RemoveUITransitionEffect,
          Items = {
              {
                Type = "Float",
                Name = "TransitionEffectFactor",
                SetFun = GUI.TransitionSetEffectFactor,
                GetFun = GUI.TransitionGetEffectFactor,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 1
              },

              {
                Type = "Enum",
                Name = "TransitionEffectMode",
                Enum = { 
                    {UIEffects.UITransitionEffectMode.Fade, "Fade"},
                    {UIEffects.UITransitionEffectMode.Cutoff, "Cutoff"},
                    {UIEffects.UITransitionEffectMode.Dissolve, "Dissolve"},
                },
                SetFun = GUI.TransitionSetEffectMode,
                GetFun = GUI.TransitionGetEffectMode,
              },
              {
                Type = "Bool",
                Name = "TransitionKeepaspectratio",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                SetFun = GUI.TransitionSetKeepAspectRatio,
                GetFun = GUI.TransitionGetKeepAspectRatio,
              },
              {
                Type = "Bool",
                Name = "TransitionPassRayOnHidden",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                SetFun = GUI.TransitionSetPassRayOnHidden,
                GetFun = GUI.TransitionGetPassRayOnHidden,
              },

              {
                Type = "Float",
                Name = "TransitionInitalPlayDelay",
                SetFun = GUI.TransitionSetInitalPlayDelay,
                GetFun = GUI.TransitionGetInitalPlayDelay,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 10
              },

              {
                Type = "Bool",
                Name = "TransitionShow",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                SetFun = GUI.TransitionShow
              },
             
              {
                Type = "Float",
                Name = "TransitionDuration",
                SetFun = GUI.TransitionSetDuration,
                GetFun = GUI.TransitionGetDuration,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 10
              },

              {
                Type = "Float",
                Name = "TransitionLoopDelay",
                SetFun = GUI.TransitionSetLoopDelay,
                GetFun = GUI.TransitionGetLoopDelay,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 10
              },
              
              {
                  Type = "Bool",
                  Name = "TransitionLoop",
                  StartValue = false,
                  Enum = {{false, "false"}, {true, "true"}},
                  GetFun = GUI.TransitionGetLoop,
                  SetFun = GUI.TransitionSetLoop
              },
              {
                Type = "Bool",
                Name = "TransitionIsPlay",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                GetFun = GUI.TransitionGetIsPlay,
                SetFun = GUI.TransitionSetIsPlay
              },
              
            }
    }, {
        EffectType = "Dissolve",
        --[[
             /**设置溶解效果插件参数
          *@param EffectFactor 效果因子Range(0, 1), 在播放时会变化
          *@param Width 溶解区域宽度[Range(0, 1)]
          *@param Softness 溶解柔软度[Range(0, 1)]
          *@param Color 溶解颜色
          *@param ColorMode 边缘颜色叠加模式ColorMode.Multiply,ColorMode.Fill,ColorMode.Add,ColorMode.Subtract
          *@param EffectArea 效果区域模式 EffectArea.RectTransform,EffectArea.Fit,EffectArea.Character
          *@param KeepAspectRatio 效果区域保持横纵比
          *@param IsPlay 是否播放
          *@param Duraion 播放持续时间(秒)
          *@param InitalPlayDelay 初始播放演出
          *@param Loop 是否循环
          *@param LoopDelay 循环间隔(秒)
          *@param UpdateMode 更新模式AnimatorUpdateMode.Norma,AnimatorUpdateMode.AnimatePhysics,AnimatorUpdateMode.UnscaledTime
          */
          -- 还有方法GUI.DissolvePlay( UIDissolveComponent obj  ,  bool reset = false  )
          -- 还有方法GUI.DissolveStop( UIDissolveComponent obj  ,  bool reset = false  )
        ]] --

        GetFun = GUI.GetUIDissolve,
        AddFun = GUI.AddUIDissolve,
        RemoveFun = GUI.RemoveUIDissolve,
        Items = {
            {
                Type = "Float",
                Name = "DissolveEffectFactor",
                SetFun = GUI.DissolveSetEffectFactor,
                GetFun = GUI.DissolveGetEffectFactor,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 1
            },
            {
                Type = "Float",
                Name = "DissolveWidth",
                SetFun = GUI.DissolveSetWidth,
                GetFun = GUI.DissolveGetWidth,
                StartValue = 0.25,
                RangeMin = 0,
                RangeMax = 1
            },
            {
                Type = "Float",
                Name = "DissolveSoftness",
                SetFun = GUI.DissolveSetSoftness,
                GetFun = GUI.DissolveGetSoftness,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 1
            },
            {
                -- *@param TargetColor 目标颜色
                Type = "Color",
                Name = "DissolveColor",
                SetFun = GUI.DissolveSetColor,
                GetFun = GUI.DissolveGetColor
            },
            {
                Type = "Enum",
                Name = "DissolveColorMode",
                Enum = {
                    {UIEffects.ColorMode.Multiply, "Multiply"},
                    {UIEffects.ColorMode.Fill, "Fill"},
                    {UIEffects.ColorMode.Add, "Add"},
                    {UIEffects.ColorMode.Subtract, "Subtract"}
                },
                SetFun = GUI.DissolveSetColorMode,
                GetFun = GUI.DissolveGetColorMode
            },

            {
                Type = "Bool",
                Name = "DissolveKeepaspectratio",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                SetFun = GUI.DissolveSetKeepAspectRatio,
                GetFun = GUI.DissolveGetKeepAspectRatio,
            },

            {
                Type = "Float",
                Name = "DissolveDuration",
                SetFun = GUI.DissolveSetDuration,
                GetFun = GUI.DissolveGetDuration,
                StartValue = 1,
                RangeMin = 0,
                RangeMax = 10
            },
            {
                Type = "Float",
                Name = "DissolveLoopDelay",
                
                SetFun = GUI.DissolveSetLoopDelay,
                StartValue = 0,
                RangeMin = 0,
                RangeMax = 10
            },
            {
                Type = "Bool",
                Name = "DissolveLoop",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                GetFun = GUI.DissolveGetLoop,
                SetFun = GUI.DissolveSetLoop
            },
            {
              Type = "Bool",
              Name = "DissolveIsPlay",
              StartValue = false,
              Enum = {{false, "false"}, {true, "true"}},
              GetFun = GUI.DissolveGetIsPlay,
              SetFun = GUI.DissolveSetIsPlay
            },
            

        }
    },
    {
        EffectType = "Shadow",

        GetFun = GUI.GetUIShadow,
        AddFun = GUI.AddUIShadow,
        RemoveFun = GUI.RemoveUIShadow,
        Items = {
            {
                Type = "Enum",
                Name = "ShadowStyle",
                Enum = {
                    {UIEffects.ShadowStyle.None, "None"},
                    {UIEffects.ShadowStyle.Shadow, "Shadow"},
                    {UIEffects.ShadowStyle.Outline, "Outline"},
                    {UIEffects.ShadowStyle.Shadow3, "Shadow3"},
                    {UIEffects.ShadowStyle.Outline8, "Outline8"}
                },
                GetFun = GUI.DissolveSetColorMode,
                SetFun = GUI.DissolveGetColorMode
            },

            {
                Type = "XY",
                Name = "ShadowEffectDistance",
                SetFun = GUI.ShadowSetEffectDistance,
                GetFun = GUI.ShadowGetEffectDistance,

            },
            {
                Type = "Color",
                Name = "ShadowEffectColor",
                SetFun = GUI.ShadowSetEffectColor,
                GetFun = GUI.ShadowGetEffectColor
            },

            {
                Type = "Bool",
                Name = "ShadowUseGraphicAlpha",
                StartValue = false,
                Enum = {{false, "false"}, {true, "true"}},
                SetFun = GUI.ShadowSetUseGraphicAlpha,
                GetFun = GUI.ShadowGetUseGraphicAlpha
            },

        }
    }
}

function TestEffectUI.Main()
    local Wnd = GUI.WndCreateWnd("TestEffectUI", "TestEffectUI", 0, 0)
    UILayout.SetAnchorAndPivot(Wnd, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local Panel = GUI.ImageCreate(Wnd, "BG", "1800001020", 0, 0, false, 1280, 720)
    _gt.BindName(Panel, "Panel")
    GUI.SetIsRaycastTarget(Panel, true)
    local Main = GUI.ButtonCreate(Panel, "Main", 1800107010, 100, 80, Transition.ColorTint, "")
    _gt.BindName(Main, "Main")
    -- 旋转中心在中点
    UILayout.SetAnchorAndPivot(Main, UIAnchor.TopLeft, UIAroundPivot.Center)


    local LeftTabGroup = GUI.GroupCreate(Panel, "LeftTabGroup", 0, 50, 150, 600)
    GUI.SetIsToggleGroup(LeftTabGroup, true)

    --更换图片
    local ChangeImage = GUI.ButtonCreate(Panel, "ChangeImage", 1800402030, 180, 80, Transition.ColorTint, "更换图片", 150, 50, false)
    GUI.RegisterUIEvent(ChangeImage, UCE.PointerClick, "TestEffectUI", "OnImageChange")
    GUI.ButtonSetTextFontSize(ChangeImage, 26)

    local ImageId = GUI.EditCreate(ChangeImage, "ImageId","1800400390", "1800107010", 155, 5,Transition.ColorTint,"system", 210, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
    GUI.SetAnchor(ImageId, UIAnchor.TopLeft)
    GUI.SetPivot(ImageId, UIAroundPivot.TopLeft)
    GUI.EditSetLabelAlignment(ImageId, TextAnchor.MiddleLeft)
    GUI.EditSetTextColor(ImageId, UIDefine.BlackColor)
    GUI.EditSetFontSize(ImageId, 20);
    _gt.BindName(ImageId, "ImageId")

    local effectTypeIndex = 0
    for _, effectItem in pairs(Data) do
        effectTypeIndex = effectTypeIndex + 1
        local LeftSubTab = GUI.CheckBoxCreate(LeftTabGroup,"LeftSubTab" .. effectTypeIndex,"1800402030", "1800402031", 20,effectTypeIndex * 60 + 30,Transition.ColorTint, false, 140,50)

        GUI.SetToggleGroupGuid(LeftSubTab, GUI.GetGuid(LeftTabGroup))
        if effectTypeIndex == 1 then
            GUI.CheckBoxSetCheck(LeftSubTab, true)
        end
        GUI.RegisterUIEvent(LeftSubTab, UCE.PointerClick, "TestEffectUI", "OnLeftSubBtnClick")
        GUI.SetData(LeftSubTab, "effectTypeIndex", effectTypeIndex)

        local LeftSubText = GUI.CreateStatic(LeftSubTab,"LeftSubText" .. effectTypeIndex,effectItem.EffectType, 0, 0, 145,45, "system", true)
        UILayout.SetAnchorAndPivot(LeftSubText, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetAlignment(LeftSubText, TextAnchor.MiddleCenter)
        GUI.SetColor(LeftSubText, UIDefine.BlackColor)
        GUI.StaticSetFontSize(LeftSubText, 22)

        local index = 0
        local EffectGroup = GUI.GroupCreate(Panel, "EffectGroup" .. effectTypeIndex, 0,  100, 1024, 768)

        -- 初始化单独的特效未写, 可以在切换特效的时候重新还原ui
        if effectItem.Items then
            for _, item in pairs(effectItem.Items) do
                index = index + 1
                local ItemGroup = GUI.GroupCreate(EffectGroup, item.Name .. "ItemGroup", 150, index * 50, 1024, 200)
                local Txt = GUI.CreateStatic(ItemGroup, item.Name .. "Txt", item.Name, 20, 0, 200, 40, "system", true)
                GUI.SetIsOutLine(Txt, true)
                GUI.SetOutLine_Setting(Txt, OutLineSetting.OutLine_BlackColor_1)
                GUI.SetOutLine_Color(Txt, UIDefine.BlackColor)
                GUI.SetOutLine_Distance(Txt, 1)
                UILayout.SetAnchorAndPivot(Txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.StaticSetFontSize(Txt, 22)
                if item.Type == "Enum" or item.Type == "Bool" then
                    local EnumGroup = GUI.GroupCreate(ItemGroup, item.Name .. "EnumGroup", 0, 0, 500, 200)
                    GUI.SetIsToggleGroup(EnumGroup, true)
                    for enumIndex = 1, #item.Enum do
                        local SubTab = GUI.CheckBoxCreate(EnumGroup,item.Enum[enumIndex][2] ..    "SubTab","1800402030","1800402031",enumIndex * 150 + 50,0,Transition.ColorTint,enumIndex == 1, 145,50)
                        GUI.SetData(SubTab, "enumIndex", enumIndex)
                        GUI.SetData(SubTab, "index", index)
                        local SubText = GUI.CreateStatic(SubTab, "SubText", item.Enum[enumIndex][2], 0, 0, 145, 45, "system", true)
                        UILayout.SetAnchorAndPivot(SubText, UIAnchor.Center, UIAroundPivot.Center)
                        GUI.StaticSetAlignment(SubText, TextAnchor.MiddleCenter)
                        GUI.SetColor(SubText, UIDefine.BlackColor)
                        GUI.RegisterUIEvent(SubTab, UCE.PointerClick, "TestEffectUI", "OnEnumBtnClick")
                        if enumIndex == 1 then
                            GUI.CheckBoxSetCheck(SubTab, true)
                        end
                        GUI.SetToggleGroupGuid(SubTab, GUI.GetGuid(EnumGroup))
                    end
                elseif item.Type == "Float" then
                    -- GUI.EffectSetEffectFactor(Effect, item.StartValue)

                    local Scroll = GUI.ScrollBarCreate(ItemGroup,item.Name .. "Slider","", "1800408160","1800408110", 202,0 + 10, 400, 24,item.StartValue, true,Transition.ColorTint, 0,1, Direction.LeftToRight,false)
                    local silderFillSize = Vector2.New(400, 24)
                    GUI.ScrollBarSetFillSize(Scroll, silderFillSize)
                    GUI.ScrollBarSetBgSize(Scroll, silderFillSize)
                    UILayout.SetAnchorAndPivot(Scroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                    GUI.SetData(Scroll, "index", index)
                    GUI.RegisterUIEvent(Scroll, ULE.ValueChange, "TestEffectUI", "OnScrollChange")

                    local Val = GUI.CreateStatic(ItemGroup, item.Name .. "Val", item.StartValue, 620, 3, 100, 40, "system", true)
                    UILayout.SetAnchorAndPivot(val, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                    GUI.StaticSetFontSize(Val, 22)
                    GUI.SetColor(Val, UIDefine.RedColor)
                    _gt.BindName(Val, item.Name .. "Val")
                    GUI.SetData(Val, "index", index)

                elseif item.Type == "Color" then
                    -- GUI.EffectSetEffectFactor(Effect, item.StartValue)
                    local ColorText = GUI.CreateStatic(ItemGroup, item.Name .. "ColorText", "■", 195, -14, 60, 60);
                    GUI.SetColor(ColorText, Color.New(255 / 255, 0 / 255, 0 / 255, 1))
                    GUI.StaticSetFontSize(ColorText, 50)
                    _gt.BindName(ColorText, item.Name .. "ColorText")

                    local RText = GUI.CreateStatic(ItemGroup, item.Name .. "RText", "R", 240, -8, 60, 60);
                    GUI.StaticSetFontSize(RText, 22)
                    GUI.SetColor(RText, UIDefine.BlackColor)

                    local GText = GUI.CreateStatic(ItemGroup, item.Name .. "GText", "G", 240 + 100, -8, 60, 60);
                    GUI.StaticSetFontSize(GText, 22)
                    GUI.SetColor(GText, UIDefine.BlackColor)

                    local BText = GUI.CreateStatic(ItemGroup, item.Name .. "BText", "B", 240 + 100 * 2, -8, 60, 60);
                    GUI.StaticSetFontSize(BText, 22)
                    GUI.SetColor(BText, UIDefine.BlackColor)

                    local RInput = GUI.EditCreate(ItemGroup,item.Name .. "RInput","1800400390", "255", 255, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(RInput, UIAnchor.TopLeft)
                    GUI.SetPivot(RInput, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(RInput, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(RInput, UIDefine.BlackColor)
                    GUI.EditSetFontSize(RInput, 20);
                    GUI.EditSetMaxCharNum(RInput, 3)
                    GUI.RegisterUIEvent(RInput, UCE.EndEdit, "TestEffectUI", "OnColorChange")
                    GUI.SetData(RInput, "index", index)
                    GUI.SetData(RInput, "colorIndex", 1)
                    _gt.BindName(RInput, item.Name .. "RInput")

                    local GInput = GUI.EditCreate(ItemGroup,item.Name .. "GInput","1800400390", "0", 355, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(GInput, UIAnchor.TopLeft)
                    GUI.SetPivot(GInput, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(GInput, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(GInput, UIDefine.BlackColor)
                    GUI.EditSetFontSize(GInput, 20);
                    GUI.EditSetMaxCharNum(GInput, 3)
                    GUI.RegisterUIEvent(GInput, UCE.EndEdit, "TestEffectUI", "OnColorChange")
                    GUI.SetData(GInput, "index", index)
                    GUI.SetData(GInput, "colorIndex", 1)
                    _gt.BindName(GInput, item.Name .. "GInput")

                    local BInput = GUI.EditCreate(ItemGroup,item.Name .. "BInput","1800400390", "0", 455, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(BInput, UIAnchor.TopLeft)
                    GUI.SetPivot(BInput, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(BInput, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(BInput, UIDefine.BlackColor)
                    GUI.EditSetFontSize(BInput, 20);
                    GUI.EditSetMaxCharNum(BInput, 3)
                    GUI.RegisterUIEvent(BInput, UCE.EndEdit, "TestEffectUI", "OnColorChange")
                    GUI.SetData(BInput, "index", index)
                    GUI.SetData(BInput, "colorIndex", 1)
                    _gt.BindName(BInput, item.Name .. "BInput")

                elseif item.Type == "XY" then

                    local XText = GUI.CreateStatic(ItemGroup, item.Name .. "XText", "X", 240, -8, 60, 60);
                    GUI.StaticSetFontSize(XText, 22)
                    GUI.SetColor(XText, UIDefine.BlackColor)

                    local YText = GUI.CreateStatic(ItemGroup, item.Name .. "YText", "Y", 240 + 100, -8, 60, 60);
                    GUI.StaticSetFontSize(YText, 22)
                    GUI.SetColor(YText, UIDefine.BlackColor)

                    local XInput = GUI.EditCreate(ItemGroup,item.Name .. "XInput","1800400390", "0", 255, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(XInput, UIAnchor.TopLeft)
                    GUI.SetPivot(XInput, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(XInput, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(XInput, UIDefine.BlackColor)
                    GUI.EditSetFontSize(XInput, 20);
                    GUI.EditSetMaxCharNum(XInput, 3)
                    GUI.RegisterUIEvent(XInput, UCE.EndEdit, "TestEffectUI", "OnXYChange")
                    GUI.SetData(XInput, "index", index)
                    GUI.SetData(XInput, "XYIndex", 1)
                    _gt.BindName(XInput, item.Name .. "XInput")

                    local YInput = GUI.EditCreate(ItemGroup,item.Name .. "YInput","1800400390", "0", 355, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(YInput, UIAnchor.TopLeft)
                    GUI.SetPivot(YInput, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(YInput, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(YInput, UIDefine.BlackColor)
                    GUI.EditSetFontSize(YInput, 20);
                    GUI.EditSetMaxCharNum(YInput, 3)
                    GUI.RegisterUIEvent(YInput, UCE.EndEdit, "TestEffectUI", "OnXYChange")
                    GUI.SetData(YInput, "index", index)
                    GUI.SetData(YInput, "XYIndex", 1)
                    _gt.BindName(YInput, item.Name .. "YInput")

                elseif item.Type == "Color1" then
                    -- GUI.EffectSetEffectFactor(Effect, item.StartValue)
                    GUI.SetPositionY(ItemGroup, index * 100)

                    local ColorText1 = GUI.CreateStatic(ItemGroup, item.Name .. "ColorText1", "■", 195, -50, 60, 60);
                    GUI.SetColor(ColorText1, Color.New(255 / 255, 0 / 255, 0 / 255, 1))
                    GUI.StaticSetFontSize(ColorText1, 50)
                    _gt.BindName(ColorText1, item.Name .. "ColorText1")

                    local RText1 = GUI.CreateStatic(ItemGroup, item.Name .. "RText1", "R", 240, -44, 60, 60);
                    GUI.StaticSetFontSize(RText1, 22)
                    GUI.SetColor(RText1, UIDefine.BlackColor)

                    local GText1 = GUI.CreateStatic(ItemGroup, item.Name .. "GText1", "G", 240 + 100, -44, 60, 60);
                    GUI.StaticSetFontSize(GText1, 22)
                    GUI.SetColor(GText1, UIDefine.BlackColor)

                    local BText1 = GUI.CreateStatic(ItemGroup, item.Name .. "BText1", "B", 240 + 100 * 2, -44, 60, 60);
                    GUI.StaticSetFontSize(BText1, 22)
                    GUI.SetColor(BText1, UIDefine.BlackColor)

                    local RInput1 = GUI.EditCreate(ItemGroup,item.Name .. "RInput1","1800400390", "255", 255, -36,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(RInput1, UIAnchor.TopLeft)
                    GUI.SetPivot(RInput1, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(RInput1, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(RInput1, UIDefine.BlackColor)
                    GUI.EditSetFontSize(RInput1, 20);
                    GUI.EditSetMaxCharNum(RInput1, 3)
                    GUI.RegisterUIEvent(RInput1, UCE.EndEdit, "TestEffectUI", "OnColor1Change")
                    GUI.SetData(RInput1, "index", index)
                    GUI.SetData(RInput1, "colorIndex", 1)
                    _gt.BindName(RInput1, item.Name .. "RInput1")

                    local GInput1 = GUI.EditCreate(ItemGroup,item.Name .. "GInput1","1800400390", "0", 355, -36,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(GInput1, UIAnchor.TopLeft)
                    GUI.SetPivot(GInput1, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(GInput1, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(GInput1, UIDefine.BlackColor)
                    GUI.EditSetFontSize(GInput1, 20);
                    GUI.EditSetMaxCharNum(GInput1, 3)
                    GUI.RegisterUIEvent(GInput1, UCE.EndEdit, "TestEffectUI", "OnColor1Change")
                    GUI.SetData(GInput1, "index", index)
                    GUI.SetData(GInput1, "colorIndex", 1)
                    _gt.BindName(GInput1, item.Name .. "GInput1")

                    local BInput1 = GUI.EditCreate(ItemGroup,item.Name .. "BInput1","1800400390", "0", 455, -36,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(BInput1, UIAnchor.TopLeft)
                    GUI.SetPivot(BInput1, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(BInput1, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(BInput1, UIDefine.BlackColor)
                    GUI.EditSetFontSize(BInput1, 20);
                    GUI.EditSetMaxCharNum(BInput1, 3)
                    GUI.RegisterUIEvent(BInput1, UCE.EndEdit, "TestEffectUI", "OnColor1Change")
                    GUI.SetData(BInput1, "index", index)
                    GUI.SetData(BInput1, "colorIndex", 1)
                    _gt.BindName(BInput1, item.Name .. "BInput1")


                    local ColorText2 = GUI.CreateStatic(ItemGroup, item.Name .. "ColorText2", "■", 195, -14, 60, 60);
                    GUI.SetColor(ColorText2, Color.New(255 / 255, 0 / 255, 0 / 255, 1))
                    GUI.StaticSetFontSize(ColorText2, 50)
                    _gt.BindName(ColorText2, item.Name .. "ColorText2")

                    local RText2 = GUI.CreateStatic(ItemGroup, item.Name .. "RText2", "R", 240, -8, 60, 60);
                    GUI.StaticSetFontSize(RText2, 22)
                    GUI.SetColor(RText2, UIDefine.BlackColor)

                    local GText2 = GUI.CreateStatic(ItemGroup, item.Name .. "GText2", "G", 240 + 100, -8, 60, 60);
                    GUI.StaticSetFontSize(GText2, 22)
                    GUI.SetColor(GText2, UIDefine.BlackColor)

                    local BText2 = GUI.CreateStatic(ItemGroup, item.Name .. "BText2", "B", 240 + 100 * 2, -8, 60, 60);
                    GUI.StaticSetFontSize(BText2, 22)
                    GUI.SetColor(BText2, UIDefine.BlackColor)

                    local RInput2 = GUI.EditCreate(ItemGroup,item.Name .. "RInput22","1800400390", "255", 255, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(RInput2, UIAnchor.TopLeft)
                    GUI.SetPivot(RInput2, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(RInput2, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(RInput2, UIDefine.BlackColor)
                    GUI.EditSetFontSize(RInput2, 20);
                    GUI.EditSetMaxCharNum(RInput2, 3)
                    GUI.RegisterUIEvent(RInput2, UCE.EndEdit, "TestEffectUI", "OnColor1Change")
                    GUI.SetData(RInput2, "index", index)
                    GUI.SetData(RInput2, "colorIndex", 1)
                    _gt.BindName(RInput2, item.Name .. "RInput2")

                    local GInput2 = GUI.EditCreate(ItemGroup,item.Name .. "GInput2","1800400390", "0", 355, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(GInput2, UIAnchor.TopLeft)
                    GUI.SetPivot(GInput2, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(GInput2, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(GInput2, UIDefine.BlackColor)
                    GUI.EditSetFontSize(GInput2, 20);
                    GUI.EditSetMaxCharNum(GInput2, 3)
                    GUI.RegisterUIEvent(GInput2, UCE.EndEdit, "TestEffectUI", "OnColor1Change")
                    GUI.SetData(GInput2, "index", index)
                    GUI.SetData(GInput2, "colorIndex", 1)
                    _gt.BindName(GInput2, item.Name .. "GInput2")

                    local BInput2 = GUI.EditCreate(ItemGroup,item.Name .. "BInput2","1800400390", "0", 455, 0,Transition.ColorTint,"system", 70, 40, 8, 8,InputType.Standard,ContentType.IntegerNumber)
                    GUI.SetAnchor(BInput2, UIAnchor.TopLeft)
                    GUI.SetPivot(BInput2, UIAroundPivot.TopLeft)
                    GUI.EditSetLabelAlignment(BInput2, TextAnchor.MiddleCenter)
                    GUI.EditSetTextColor(BInput2, UIDefine.BlackColor)
                    GUI.EditSetFontSize(BInput2, 20);
                    GUI.EditSetMaxCharNum(BInput2, 3)
                    GUI.RegisterUIEvent(BInput2, UCE.EndEdit, "TestEffectUI", "OnColor1Change")
                    GUI.SetData(BInput2, "index", index)
                    GUI.SetData(BInput2, "colorIndex", 1)
                    _gt.BindName(BInput2, item.Name .. "BInput2")

                    local Scroll = GUI.ScrollBarCreate(ItemGroup, item.Name .. "Slider","", "1800408160","1800408110", 202, 50, 400, 24,item.StartValue, true,Transition.ColorTint, 0,1, Direction.LeftToRight,false)
                    local silderFillSize = Vector2.New(400, 24)
                    GUI.ScrollBarSetFillSize(Scroll, silderFillSize)
                    GUI.ScrollBarSetBgSize(Scroll, silderFillSize)
                    UILayout.SetAnchorAndPivot(Scroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                    GUI.SetData(Scroll, "index", index)
                    GUI.RegisterUIEvent(Scroll, ULE.ValueChange, "TestEffectUI", "OnColor1Change")
                    _gt.BindName(Scroll, item.Name .. "Scroll")

                    local Val = GUI.CreateStatic(ItemGroup, item.Name .. "Val", item.StartValue, 620, 50, 100, 40, "system", true)
                    UILayout.SetAnchorAndPivot(val, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                    GUI.StaticSetFontSize(Val, 22)
                    GUI.SetColor(Val, UIDefine.RedColor)
                    _gt.BindName(Val, item.Name .. "Val")
                    GUI.SetData(Val, "index", index)

                end
            end
        end
    end
    -- 默认切换到第一个特效
    TestEffectUI.ToggleEffect(1)
end
function TestEffectUI.OnShow() end

--特效之间相互排斥，而翻转特效、渐变色特效和阴影特效可以和其他特效同时存在。

-- EffectMode 特效类型 参数：UIEffects.EffectMode.None, UIEffects.EffectMode.Grayscale, UIEffects.EffectMode.Sepia, {UIEffects.EffectMode.Nega, UIEffects.EffectMode.Pixel
-- EffectFactor 特效系数 参数范围 [0, 1]
-- ColorMode 颜色叠加模式  参数: UIEffects.ColorMode.Multiply, UIEffects.ColorMode.Fill, UIEffects.ColorMode.Add, UIEffects.ColorMode.Subtract
-- ColorFactor 颜色叠加因子  参数范围 [0, 1]
-- BlurMode 模糊模式 参数: UIEffects.BlurMode.None, UIEffects.BlurMode.FastBlur, UIEffects.BlurMode.MediumBlur, UIEffects.BlurMode.DetailBlur
-- BlurFactor 模糊因子 参数范围 [0, 1]
-- AdvancedBlur 不知道啥玩意，参数: true false
-- Horizontal 左右翻转 参数: true false
-- Veritical 上下翻转 参数: true false
-- TargetColor 目标颜色 参数 Color.New(255 / 255, 0 / 255, 0 / 255, 1)
-- Range 特效范围 参数范围 [0, 1]
-- Hue 色相 参数范围 [-0.5, 0.5]
-- Saturation 饱和度 参数范围 [-0.5, 0.5]
-- Value 色调 参数范围 [-0.5, 0.5]
-- Width 特效宽度 参数范围 [0, 1]
-- Rotation 旋转 参数范围 [-180, 180]
-- Softness 柔软度 参数范围 [0, 1]
-- Brightness 亮度 参数范围 [0, 1]
-- Gloss 光泽 参数范围 [0, 1]
-- Duration 播放持续时间(秒) 参数范围 [0, 10]
-- LoopDelay 循环间隔(秒) 参数范围 [0, 10]
-- Loop 是否循环（与播放相关） 参数: true false
-- IsPlay 是否进行播放（播放一次，如果loop打开就是循环播放） 参数: true false
-- KeepAspectRatio 效果区域保持横纵比 参数: true false
-- PassRayOnHidden 参数: true false
-- InitalPlayDelay  初始播放延迟 参数范围 [0, 10]
-- Play 进行播放 参数: true false



--特效  参数
-- EffectMode 特效类型 参数：UIEffects.EffectMode.None, UIEffects.EffectMode.Grayscale, UIEffects.EffectMode.Sepia, {UIEffects.EffectMode.Nega, UIEffects.EffectMode.Pixel
-- EffectFactor 特效系数 参数范围 [0, 1]
-- ColorMode 颜色叠加模式  参数: UIEffects.ColorMode.Multiply, UIEffects.ColorMode.Fill, UIEffects.ColorMode.Add, UIEffects.ColorMode.Subtract
-- ColorFactor 颜色叠加因子  参数范围 [0, 1]
-- BlurMode 模糊模式 参数: UIEffects.BlurMode.None, UIEffects.BlurMode.FastBlur, UIEffects.BlurMode.MediumBlur, UIEffects.BlurMode.DetailBlur
-- BlurFactor 模糊因子 参数范围 [0, 1]
-- AdvancedBlur 不知道啥玩意，参数: true false
function TestEffectUI.SetUIEffect(Panel, EffectMode, EffectFactor, ColorMode, ColorFactor, BlurMode, BlurFactor, AdvancedBlur)
    local EffectData = Data[1]
    if EffectData.AddFun then
        EffectData.AddFun(Panel)
    end
    local Effect = EffectData.GetFun(Panel)
    EffectData.Items[1].SetFun(Effect, EffectMode or UIEffects.EffectMode.None)
    EffectData.Items[2].SetFun(Effect, EffectFactor or 0)
    EffectData.Items[3].SetFun(Effect, ColorMode or UIEffects.ColorMode.Multiply )
    EffectData.Items[4].SetFun(Effect, ColorFactor or 0)
    EffectData.Items[5].SetFun(Effect, BlurMode or UIEffects.BlurMode.None)
    EffectData.Items[6].SetFun(Effect, BlurFactor or 0)
    EffectData.Items[7].SetFun(Effect, AdvancedBlur or false)
    return Panel
end

--翻转特效 参数
-- Horizontal 左右翻转 参数: true false
-- Veritical 上下翻转 参数: true false
function TestEffectUI.SetUIFlip(Panel, Horizontal, Veritical)
    local FlipData = Data[2]
    if FlipData.AddFun then
        FlipData.AddFun(Panel)
    end
    local Effect = FlipData.GetFun(Panel)
    FlipData.Items[1].SetFun(Effect, Horizontal or false)
    FlipData.Items[2].SetFun(Effect, Veritical or false)
    return Panel
end

--渐变色特效
function TestEffectUI.SetUIGradient(Panel)
    local GradientData = Data[3]
    if GradientData.AddFun then
        GradientData.AddFun(Panel)
    end
    local Effect = GradientData.GetFun(Panel)
end

--阴影特效 参数
-- EffectDistance 阴影特效距离 参数: Vector2.New(0, 0)
-- EffectColor 阴影特效颜色 参数 Color.New(255 / 255, 0 / 255, 0 / 255, 1)
-- UseGraphicAlpha 使用图形Alpha 参数: true false
function TestEffectUI.SetUIShadow(Panel, EffectDistance, EffectColor, UseGraphicAlpha)
    local ShadowData = Data[8]
    if ShadowData.AddFun then
        ShadowData.AddFun(Panel)
    end
    local Effect = ShadowData.GetFun(Panel)
    ShadowData.Items[1].SetFun(Effect, EffectDistance or Vector2.New(0, 0))
    ShadowData.Items[2].SetFun(Effect, EffectColor or UIDefine.RedColor)
    ShadowData.Items[3].SetFun(Effect, UseGraphicAlpha or false)
    return Panel
end

--色彩特效 参数
-- TargetColor 目标颜色 参数 Color.New(255 / 255, 0 / 255, 0 / 255, 1)
-- Range 特效范围 参数范围 [0, 1]
-- Hue 色相 参数范围 [-0.5, 0.5]
-- Saturation 饱和度 参数范围 [-0.5, 0.5]
-- Value 色调 参数范围 [-0.5, 0.5]
function TestEffectUI.SetUIHsvModifier(Panel, TargetColor, Range, Hue, Saturation, Value)
    local HsvModifierData = Data[4]
    if HsvModifierData.AddFun then
        HsvModifierData.AddFun(Panel)
    end
    local Effect = HsvModifierData.GetFun(Panel)
    HsvModifierData.Items[1].SetFun(Effect, TargetColor or UIDefine.RedColor)
    HsvModifierData.Items[2].SetFun(Effect, Range or 0)
    HsvModifierData.Items[3].SetFun(Effect, Hue or 0)
    HsvModifierData.Items[4].SetFun(Effect, Saturation or 0)
    HsvModifierData.Items[5].SetFun(Effect, Value or 0)
    return Panel
end

--闪光特效
-- EffectFactor 特效系数 参数范围 [0, 1]
-- Width 特效宽度 参数范围 [0, 1]
-- Rotation 旋转 参数范围 [-180, 180]
-- Softness 柔软度 参数范围 [0, 1]
-- Brightness 亮度 参数范围 [0, 1]
-- Gloss 光泽 参数范围 [0, 1]
-- Duration 播放持续时间(秒) 参数范围 [0, 10]
-- LoopDelay 循环间隔(秒) 参数范围 [0, 10]
-- Loop 是否循环（与播放相关） 参数: true false
-- IsPlay 是否进行播放（播放一次，如果loop打开就是循环播放） 参数: true false
function TestEffectUI.SetUIShiny(Panel, EffectFactor, Width, Rotation, Softness, Brightness, Gloss, Duration, LoopDelay, Loop, IsPlay)
    local ShinyData = Data[5]
    if ShinyData.AddFun then
        ShinyData.AddFun(Panel)
    end
    local Effect = ShinyData.GetFun(Panel)
    ShinyData.Items[1]["SetFun"](Effect, EffectFactor or 0.5)
    ShinyData.Items[2]["SetFun"](Effect, Width or 0.25)
    ShinyData.Items[3]["SetFun"](Effect, Rotation or 0)
    ShinyData.Items[4]["SetFun"](Effect, Softness or 1)
    ShinyData.Items[5]["SetFun"](Effect, Brightness or 1)
    ShinyData.Items[6]["SetFun"](Effect, Gloss or 1)
    ShinyData.Items[7]["SetFun"](Effect, Duration or 1)
    ShinyData.Items[8]["SetFun"](Effect, LoopDelay or 0)
    ShinyData.Items[9]["SetFun"](Effect, Loop or true)
    ShinyData.Items[10]["SetFun"](Effect, IsPlay or true)
    return Panel
end

--UIEffects.UITransitionEffectMode.Fade
--UIEffects.UITransitionEffectMode.Cutoff
--UIEffects.UITransitionEffectMode.Dissolve
--ChildSync 子节点是否同步，需要同步传1

--渐变动画特效(三种)
function TestEffectUI.SetUITransition(Panel, EffectFactor, EffectMode, KeepAspectRatio, PassRayOnHidden, InitalPlayDelay, Play, Duration,LoopDelay,Loop, IsPlay)
    local TransitionData = Data[6]
    if TransitionData.AddFun then
        TransitionData.AddFun(Panel)
    end

    local Effect = TransitionData.GetFun(Panel)
    TransitionData.Items[1]["SetFun"](Effect, EffectFactor or 0.5)
    TransitionData.Items[2]["SetFun"](Effect, EffectMode or UIEffects.UITransitionEffectMode.Fade)
    TransitionData.Items[3]["SetFun"](Effect, KeepAspectRatio or false)
    TransitionData.Items[4]["SetFun"](Effect, PassRayOnHidden or false)
    TransitionData.Items[5]["SetFun"](Effect, InitalPlayDelay or 1)
    TransitionData.Items[6]["SetFun"](Effect, Play or false)
    TransitionData.Items[7]["SetFun"](Effect, Duration or 1)
    TransitionData.Items[8]["SetFun"](Effect, LoopDelay or 0)
    TransitionData.Items[9]["SetFun"](Effect, Loop or false)
    TransitionData.Items[10]["SetFun"](Effect, IsPlay or false)
    
    return Panel
end

--TestEffectUI.SetUIDissolve(Panel, 0.5, 0.25, 1, UIDefine.RedColor, UIEffects.ColorMode.Add, false, 1,0, false, true)
--ChildSync 子节点是否同步，需要同步传1
--溶解特效
function TestEffectUI.SetUIDissolve(Panel, EffectFactor, Width, Softness, Color, ColorMode, KeepAspectRatio, Duration, LoopDelay, Loop, IsPlay)
    local DissolveData = Data[7]
    if DissolveData.AddFun then
        DissolveData.AddFun(Panel)
    end

    local Effect = DissolveData.GetFun(Panel)
    if tostring(IsPlay) == "true" then
        DissolveData.Items[4].SetFun(Effect, Color or UIDefine.RedColor)
        DissolveData.Items[5].SetFun(Effect, ColorMode or UIEffects.ColorMode.Add)
        DissolveData.Items[6].SetFun(Effect, KeepAspectRatio or false)
        DissolveData.Items[7].SetFun(Effect, Duration or 1)
        DissolveData.Items[8].SetFun(Effect, LoopDelay or 0)
        DissolveData.Items[9].SetFun(Effect, Loop or false)
        DissolveData.Items[10].SetFun(Effect, IsPlay or false)
    else
        DissolveData.Items[1].SetFun(Effect, EffectFactor or 0.5)
        DissolveData.Items[2].SetFun(Effect, Width or 0.25)
        DissolveData.Items[3].SetFun(Effect, Softness or 1)
        DissolveData.Items[4].SetFun(Effect, Color or UIDefine.RedColor)
        DissolveData.Items[5].SetFun(Effect, ColorMode or UIEffects.ColorMode.Add)
        DissolveData.Items[6].SetFun(Effect, KeepAspectRatio or false)
        DissolveData.Items[7].SetFun(Effect, Duration or 1)
        DissolveData.Items[8].SetFun(Effect, LoopDelay or 0)
        DissolveData.Items[9].SetFun(Effect, Loop or false)
        DissolveData.Items[10].SetFun(Effect, IsPlay or false)
    end
    return Panel
end

--清除特效
function TestEffectUI.RemoveUIDissolve(Panel)
    local DissolveData = Data[7]
    if DissolveData.RemoveFun then
        DissolveData.RemoveFun(Panel)
    end
end


function TestEffectUI.OnEnumBtnClick(btn)
    local enumIndex = tonumber(GUI.GetData(GUI.GetByGuid(btn), "enumIndex"))
    local index = tonumber(GUI.GetData(GUI.GetByGuid(btn), "index"))
    local effectData = Data[TestEffectUI.SelectedIndex]
    local item = effectData.Items[index]
    local Effect = effectData.GetFun(_gt.GetUI("Main"))
    local enum = item.Enum
    -- 对应ui特效的设置方法
    print(tostring(enum[enumIndex][1]))
    item["SetFun"](Effect, enum[enumIndex][1])
    GUI.ButtonSetText(_gt.GetUI(item.Name .. "Btn"), enum[enumIndex][2])
    print(jsonUtil.encode({
        index = index,
        enumIndex = enumIndex,
        type = item.Type,
        name = item.Name,
        effectType = effectType
    }))
end
function TestEffectUI.OnScrollChange(btn, value)
    test("OnScrollChange")
    local effectType = tonumber(GUI.GetData(GUI.GetByGuid(btn), "effectType"))
    local index = tonumber(GUI.GetData(GUI.GetByGuid(btn), "index"))
    local effectData = Data[TestEffectUI.SelectedIndex]
    local item = effectData.Items[index]
    local Effect = effectData.GetFun(_gt.GetUI("Main"))
    -- 浮点数在Range返回内计算
    local ret = item.RangeMin + (item.RangeMax - item.RangeMin) * value
    local ret2f = tonumber(string.format("%.2f", ret))
    print(jsonUtil.encode({
        index = index,
        type = item.Type,
        name = item.Name,
        value = value,
        ret2f = ret2f,
        effectType = effectType
    }))
    -- 对应ui特效的设置方法
    item["SetFun"](Effect, ret2f)
    GUI.StaticSetText(_gt.GetUI(item.Name .. "Val"), ret2f)
end

function TestEffectUI.OnImageChange(btn)
    local Main = _gt.GetUI("Main")
    local ImageId = _gt.GetUI("ImageId")
    local id = GUI.EditGetTextM(ImageId)

    GUI.ButtonSetImageID(Main, id)
end

function TestEffectUI.OnXYChange(btn)
    local index = tonumber(GUI.GetData(GUI.GetByGuid(btn),"index"))
    local effectData = Data[TestEffectUI.SelectedIndex]
    local item = effectData.Items[index]
    local Effect = effectData.GetFun(_gt.GetUI("Main"))

    local XVal = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."XInput"))) or 0
    local YVal = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."YInput"))) or 0
    if XVal > 500 then
        XVal = 500
        GUI.EditSetTextM(_gt.GetUI(item.Name.."XInput"), 500)
    end
    if YVal > 500 then
        YVal = 500
        GUI.EditSetTextM(_gt.GetUI(item.Name.."YInput"), 500)
    end

    local ChangeXY = Vector2.New(XVal, YVal)

    item["SetFun"](Effect, ChangeXY)
end

--  todo Color
function TestEffectUI.OnColorChange(btn)
    local index = tonumber(GUI.GetData(GUI.GetByGuid(btn),"index"))
    local effectData = Data[TestEffectUI.SelectedIndex]
    local item = effectData.Items[index]
    local Effect = effectData.GetFun(_gt.GetUI("Main"))

    local RVal = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."RInput"))) or 0
    local GVal = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."GInput"))) or 0
    local BVal = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."BInput"))) or 0
    if RVal > 255 then
        RVal = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."RInput"), 255)
    end
    if GVal > 255 then
        GVal = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."GInput"), 255)
    end
    if BVal > 255 then
        BVal = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."BInput"), 255)
    end

    test("R:"..RVal.." G:"..GVal.." B:"..BVal)

    local ChangeColor = Color.New(RVal / 255, GVal / 255, BVal / 255, 1)
    local ColorText = _gt.GetUI(item.Name.."ColorText")

    GUI.SetColor(ColorText, ChangeColor)
    test(item["SetFun"])
    item["SetFun"](Effect, ChangeColor)
    -- GUI.StaticSetText(_gt.GetUI(item.Name .. "Val"), ret2f)
    -- print(jsonUtil.encode({
    --   index = index,
    --   type = item.Type,
    --   name = item.Name,
    --   value = value,
    --   ret2f = ret2f,
    -- }))
end

--  todo Color
function TestEffectUI.OnColor1Change(btn, value)
    local index = tonumber(GUI.GetData(GUI.GetByGuid(btn),"index"))
    local effectData = Data[TestEffectUI.SelectedIndex]
    local item = effectData.Items[index]
    local Effect = effectData.GetFun(_gt.GetUI("Main"))

    local RVal1 = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."RInput1"))) or 0
    local GVal1 = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."GInput1"))) or 0
    local BVal1 = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."BInput1"))) or 0
    if RVal1 > 255 then
        RVal1 = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."RInput"), 255)
    end
    if GVal1 > 255 then
        GVal1 = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."GInput"), 255)
    end
    if BVal1 > 255 then
        BVal1 = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."BInput"), 255)
    end

    local RVal2 = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."RInput2"))) or 0
    local GVal2 = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."GInput2"))) or 0
    local BVal2 = tonumber(GUI.EditGetTextM(_gt.GetUI(item.Name.."BInput2"))) or 0
    if RVal2 > 255 then
        RVal2 = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."RInput"), 255)
    end
    if GVal2 > 255 then
        GVal2 = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."GInput"), 255)
    end
    if BVal2 > 255 then
        BVal2 = 255
        GUI.EditSetTextM(_gt.GetUI(item.Name.."BInput"), 255)
    end

    --test("R:"..RVal.." G:"..GVal.." B:"..BVal)

    local ChangeColor1 = Color.New(RVal1 / 255, GVal1 / 255, BVal1 / 255, 1)
    local ChangeColor2 = Color.New(RVal2 / 255, GVal2 / 255, BVal2 / 255, 1)
    local ColorText1 = _gt.GetUI(item.Name.."ColorText1")
    local ColorText2 = _gt.GetUI(item.Name.."ColorText2")
    
    GUI.SetColor(ColorText1, ChangeColor1)
    GUI.SetColor(ColorText2, ChangeColor2)

    -- 浮点数在Range返回内计算
    local Scroll = _gt.GetUI(item.Name .. "Scroll")
    local value = GUI.ScrollBarGetPos(Scroll)
    --print(GUI.ScrollBarGetPos(Scroll))
    local ret = item.RangeMin + (item.RangeMax - item.RangeMin) * value
    local ret2f = tonumber(string.format("%.2f", ret))

    -- 对应ui特效的设置方法
    GUI.StaticSetText(_gt.GetUI(item.Name .. "Val"), ret2f)

    --test(item["SetFun"])
    item["SetFun"](Effect, ChangeColor1, ChangeColor2, ret2f)
end

-- 切换ui特效
function TestEffectUI.OnLeftSubBtnClick(btn)
    local effectTypeIndex = tonumber(GUI.GetData(GUI.GetByGuid(btn), "effectTypeIndex"))
    TestEffectUI.ToggleEffect(effectTypeIndex)
end

function TestEffectUI.ToggleEffect(effectTypeIndex)
    local Panel = _gt.GetUI("Panel")
    local Main = _gt.GetUI("Main")
    local EffectGroup = GUI.GetChild(Panel, "EffectGroup" .. effectTypeIndex)
    --  移除之前的ui特效
    if TestEffectUI.SelectedIndex and Data[TestEffectUI.SelectedIndex] and Data[TestEffectUI.SelectedIndex].RemoveFun then
        print("RemoveFun")
        --print(Main)
        --print(Data[TestEffectUI.SelectedIndex].RemoveFun)
        Data[TestEffectUI.SelectedIndex].RemoveFun(Main);
    end
    for i = 0, #Data do
        if i == effectTypeIndex then
            GUI.SetVisible(EffectGroup, true)
            --  新增ui特效
            if Data[i].AddFun then
                print("AddFun")
                Data[i].AddFun(Main);
            end
        else
            GUI.SetVisible(GUI.GetChild(Panel, "EffectGroup" .. i), false)
        end
    end
    TestEffectUI.SelectedIndex = effectTypeIndex
end
