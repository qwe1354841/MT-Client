local RedPointMgr = {}
_G.RedPointMgr = RedPointMgr

RedPointMgr.Data={};


function RedPointMgr.AddRedPointEvent(element,GM,conditionFun)
  if element==nil or GM==nil or conditionFun==nil then
    return;
  end

  if RedPointMgr.Data[GM]==nil then
    RedPointMgr.Data[GM]={};

    local funName = "GMFun"..System.Enum.ToInt(GM)
    RedPointMgr[funName]=function()

      for k, v in pairs(RedPointMgr.Data[GM]) do
        local element = GUI.GetByGuid(k);
        GUI.SetRedPointVisable(element,v());
      end
    end
    CL.RegisterMessage(GM, "RedPointMgr", funName);
  end

  RedPointMgr.Data[GM][GUI.GetGuid(element)]=conditionFun;
  GUI.SetRedPointVisable(element,conditionFun());
end

function RedPointMgr.DelRedPointEvent(element,GM)
  if element==nil then
    return;
  end

  if RedPointMgr.Data[GM]==nil then
    return;
  end

  RedPointMgr.Data[GM][GUI.GetGuid(element)]=nil;

  if next(RedPointMgr.Data[GM])==nil then
    RedPointMgr.Data[GM]=nil;
    local funName = "GMFun"..System.Enum.ToInt(GM)
    CL.UnRegisterMessage(GM, "RedPointMgr", funName);
  end
end



