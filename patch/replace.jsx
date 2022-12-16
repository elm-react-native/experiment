
var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
  return F2(function(factList, kidList)
  {
    return <ElmNodeComponent tag={tag} factList={factList} kidList={kidList} />;
  });
});

var _VirtualDom_map = F2(function(tagger, node)
{
  return <ElmMapComponent tagger={tagger} node={node} />;
});

function _VirtualDom_text(string)
{
  if (scope.isReactNative) {
    return <ElmNodeComponent tag="Text" factList={_List_Nil} kidList={_List_Cons(string, _List_Nil)} />
  }
  return string;
}

var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
  return F2(function(factList, kidList)
  {
    return <ElmKeyedNodeComponent tag={tag} factList={factList} kidList={kidList} />;
  });
});

function _VirtualDom_thunk(refs, thunk)
{
  return <ElmThunkComponent refs={refs} thunk={thunk} />;
}


var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
  return _Platform_initialize(
    flagDecoder,
    args,
    impl.init,
    impl.update,
    impl.subscriptions,
    function(sendToApp, initialModel) {
      args.onInit(initialModel, impl.view, sendToApp);
      return _Browser_makeAnimator(initialModel, args.onModelChanged);
    }
  );
});

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
  return _Platform_initialize(
    flagDecoder,
    args,
    impl.init,
    impl.update,
    impl.subscriptions,
    function(sendToApp, initialModel) {
      var divertHrefToApp = impl.setup && impl.setup(sendToApp)
      var view = impl.view;
      var title = _VirtualDom_doc.title;

      args.onInit(initialModel, impl.view, sendToApp, title);
      return _Browser_makeAnimator(initialModel, function(model)
      {
        _VirtualDom_divertHrefToApp = divertHrefToApp;
        args.onModelChanged(model);
        _VirtualDom_divertHrefToApp = 0;
      });
    }
  );
});
