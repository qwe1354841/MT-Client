require "LuaPollfill"
-- LuaPollfill.Start()
GuideData = {
    ServerData = {
        --[[{
             x = 0,
             y = 0,
             w = 1280,
             h = 1000,
             str = "1",
             ali = 5,
             ui = {},
             type=1,--1是强引导，其他为弱引导
             time=41111,
             parm = ""
         },
        {
            x = 1005,
            y = 25,
            w = 80,
            h = 80,
            str = "1111",
            ali = 1,
            time=5,
            type=1
        },
        {
            x = 0,
            y = 25,
            w = 80,
            h = 80,
            str = "2",
            ali = 2,
            type=0
        },
        {
            x = -135,
            y = 25,
            w = 80,
            h = 80,
            str = "3",
            ali = 3,
            type=1
        },
        {
            x = 135,
            y = 0,
            w = 80,
            h = 80,
            str = "4",
            ali = 4,
            type=1
        },
        {
            x = 0,
            y = 0,
            w = 80,
            h = 80,
            str = "5",
            ali = 5,
            type=1
        },
        {
            x = -135,
            y = 0,
            w = 80,
            h = 80,
            str = "6",
            ali = 6,
            type=1
        },
        {
            x = 135,
            y = -25,
            w = 80,
            h = 80,
            str = "7",
            ali = 7,
            type=1
        },
        {
            x = 0,
            y = -25,
            w = 80,
            h = 80,
            str = "8",
            ali = 8,
            type=1
        },
        {
            x = -135,
            y = -25,
            w = 80,
            h = 80,
            str = "9",
            ali = 9,
            type=1
        }
        --]]
    }
}
function GuideData.GuideData()
    GuideData.ServerData = {}
end
GameMain.AddListen("GuideData", "OnExitGame")
