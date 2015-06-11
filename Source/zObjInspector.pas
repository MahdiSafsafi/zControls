// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zObjInspector.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2015 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

unit zObjInspector;

interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.Types,
  System.UITypes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Styles,
  Vcl.Themes,
  Vcl.GraphUtil,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  zBase,
  zCanvasStack,
  zRecList,
  zUtils,
  Generics.Collections,
  Generics.Defaults,
  RTTI,
  Typinfo;

const
  vtUnknown = 0;
  vtEnum = 1;
  vtSet = 2;
  vtSetElement = 3;
  vtObj = 4;
  vtMethod = 5;
  vtBool = 6;
  vtString = 7;
  vtChar = 8;
  vtColor = 9;
  vtCursor = 10;
  vtFont = 11;
  vtIcon = 12;

  dcInit = 0;
  dcBeforeDestroying = 1;
  dcShow = 2;
  dcFinished = 3;

type
  TzObjInspectorBase = class;
  TzObjInspectorList = class;
  TzObjInspectorSizing = class;
  TzObjInspectorHeader = class;
  TzScrollObjInspectorList = class;
  TzCustomObjInspector = class;
  TzObjectInspector = class;
  TzObjectInspectorStyleHook = class;
  TzPopupListBox = class;
  TzPropInspButton = class;
  TzPropInspEdit = class;
  TzCustomValueManager = class;
  TzRttiType = class;
  TPropList = class;
  TPopupListClass = class of TzPopupListBox;
  THeaderItem = (hiProp, hiVal);
  TItemHintWindow = class;
  TzObjectHost = class;
  TzInspDialog = class;
  PPropItem = ^TPropItem;

  TPropItem = record
    Parent: PPropItem;
    Prop: TRttiProperty;
    Component: TObject;
    SetElementValue: Integer;
    Insp: TControl;
    Instance: TObject;
    FIsCategory: Boolean;
    CategoryIndex: Integer;
  private
    FVisible: Boolean;
    FQName: String;
    FItems: TPropList;
    function GetCount: Integer;
    function GetItem(const Index: Integer): PPropItem;
    function GetHasChild: Boolean;
    function GetDynInstance: TObject;
    function GetExpanded: Boolean;
    function GetValue: TValue;
    function GetName: String;
    function GetValueName: String;
    function GetVisible: Boolean;
    procedure CheckItemsList;
    function GetComponentRoot: TCustomForm;
  public
    function EqualTo(A: PPropItem): Boolean;
    function IsEmpty: Boolean;
    class function Empty: TPropItem; static;
    function IsEnum: Boolean;
    function IsCategory: Boolean;
    function IsClass: Boolean;
    function IsSet: Boolean;
    function IsSetElement: Boolean;
    function MayHaveChild: Boolean;
    property ComponentRoot: TCustomForm read GetComponentRoot;
    property Count: Integer read GetCount;
    property Items[const index: Integer]: PPropItem read GetItem;
    property HasChild: Boolean read GetHasChild;
    property Expanded: Boolean read GetExpanded;
    property QualifiedName: String read FQName;
    property Value: TValue read GetValue;
    property Name: String read GetName;
    property ValueName: String read GetValueName;
    property Visible: Boolean read GetVisible;
  end;

  TPropList = class(TzRecordList<TPropItem, PPropItem>)
    procedure FreeRecord(P: Pointer); override;
    function IndexOfQName(QName: String): Integer;
    procedure Sort;
  end;

  TPropItemEvent = function(Sender: TControl; PItem: PPropItem): Boolean of object;
  TSplitterPosChangedEvent = procedure(Sender: TControl; var Pos: Integer) of object;
  THeaderMouseDownEvent = procedure(Sender: TControl; Item: THeaderItem; X, Y: Integer) of object;
  TItemSetValue = function(Sender: TControl; PItem: PPropItem; var NewValue: TValue): Boolean of object;

  TzRttiType = class(TRttiType)
    function GetUsedProperties: TArray<TRttiProperty>;
  end;

  TzCustomValueManager = class
  protected
    /// <summary> Use custom ListBox .
    /// </summary>
    class function GetListClass(const PItem: PPropItem): TPopupListClass;
    class procedure SetValue(const PItem: PPropItem; var Value: TValue); virtual;
    class function StrToValue<T>(const PItem: PPropItem; const s: string): T;
    class function GetValue(const PItem: PPropItem; const Value): TValue; virtual;
    class function GetValueAs<T>(const Value: TValue): T;
    class function GetValueName(const PItem: PPropItem): string; virtual;
    /// <summary> Check if item can assign value that is not listed in ListBox .
    /// </summary>
    class function ValueHasOpenProbabilities(const PItem: PPropItem): Boolean; virtual;
    /// <summary> Check if value has an ExtraRect like (Color,Boolean)type .
    /// </summary>
    /// <returns> non zero to indicate that value must use an ExtraRect .
    /// </returns>
    class function GetExtraRectWidth(const PItem: PPropItem): Integer; virtual;
    class function GetValueType(const PItem: PPropItem): Integer; virtual;
    /// <summary> Paint item value name .
    /// </summary>
    class procedure PaintValue(Canvas: TCanvas; Index: Integer; const PItem: PPropItem; R: TRect); virtual;
    /// <summary> Check if the current item can have button .
    /// </summary>
    class function HasButton(const PItem: PPropItem): Boolean; virtual;
    /// <summary> Check if the current item can drop ListBox .
    /// </summary>
    class function HasList(const PItem: PPropItem): Boolean; virtual;
    /// <summary> Check if the current item have customized dialog .
    /// </summary>
    class function HasDialog(const PItem: PPropItem): Boolean; virtual;
    /// <summary> Get customized dialog for current item .
    /// </summary>
    class function GetDialog(const PItem: PPropItem): TComponentClass; virtual;
    class procedure DialogCode(const PItem: PPropItem; Dialog: TComponent; Code: Integer); virtual;
    /// <summary> Get the value returned after editing from the dialog .
    /// </summary>
    class function DialogResultValue(const PItem: PPropItem; Dialog: TComponent): TValue; virtual;
    /// <summary> Return ListBox items for the current item .
    /// </summary>
    class procedure GetListItems(const PItem: PPropItem; Items: TStrings); virtual;
    /// <summary> Get the value when the user click the ExtraRect .
    /// </summary>
    class function GetExtraRectResultValue(const PItem: PPropItem): TValue; virtual;
  end;

  TzCustomValueManagerClass = class of TzCustomValueManager;

  TItemHintWindow = class(THintWindow)
  private
    FPaintBold: Boolean;
  public
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: TCustomData): TRect; override;
  protected
    procedure Paint; override;
  end;

  TzInspDialog = class(TForm)
  private
    FPropItem: PPropItem;
    procedure SetPropItem(const Value: PPropItem);
  protected
    procedure InitDialog; virtual;
    procedure DoCreate; override;
  public
    property PropItem: PPropItem read FPropItem write SetPropItem;

  end;

  TzPropInspButton = class(TzCustomControl)
  private
    FDropDown: Boolean;
  protected
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property DropDown: Boolean read FDropDown write FDropDown;
  end;

  TzPopupListBox = class(TCustomListBox)
  private
    FPropItem: PPropItem;
    FPropEdit: TzPropInspEdit;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    property PropInfo: PPropItem read FPropItem;
    property PropEdit: TzPropInspEdit read FPropEdit;
    property ItemHeight;
  end;

  { TzPropInspEdit may not used outside of this unit ! }
  TzPropInspEdit = class(TCustomEdit)
  private
    FInspector: TzCustomObjInspector;
    FPropItem: PPropItem;
    FButton: TzPropInspButton;
    FList: TzPopupListBox;
    FTxtChanged: Boolean;
    FDefSelIndex: Integer;
    procedure CMVISIBLECHANGED(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure WMKEYDOWN(var Message: TWMKEYDOWN); message WM_KEYDOWN;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLBUTTONDBLCLK(var Message: TWMLBUTTONDBLCLK); message WM_LBUTTONDBLCLK;
    procedure WMCHAR(var Message: TWMCHAR); message WM_CHAR;
    procedure WMKILLFOCUS(var Message: TWMKILLFOCUS); message WM_KILLFOCUS;
    procedure CMCANCELMODE(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure WMWINDOWPOSCHANGED(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MouseMove;
    procedure SetPropItem(const Value: PPropItem);
  protected
    procedure DoDblClick;
    procedure ShowModalDialog;
    procedure UpdateEditText;
    procedure DoSetValueFromList;
    procedure DoSetValueFromEdit;
    procedure InitList;
    procedure ShowList;
    procedure HideList;
    procedure UpdateButton;
    procedure WndProc(var Message: TMessage); override;
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PropInfoChanged;
  public
    constructor Create(AOwner: TComponent; Inspector: TzCustomObjInspector); overload;
    { Do not publish any property ! }
    property PropInfo: PPropItem read FPropItem write SetPropItem;
    property AlignWithMargins;
    property Cursor;
    property CustomHint;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property Left;
    property Margins;
    property Name;
    property ParentCustomHint;
    property TabStop;
    property Tag;
    property Top;
    property Width;

  end;

  TzObjectInspectorStyleHook = class(TScrollingStyleHook)
  private
    procedure WMVScroll(var Msg: TMessage); message WM_VSCROLL;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TPairObjectName = TPair<TObject, String>;

  TzObjectHost = class
  private
    FList: TList<TPairObjectName>;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AddObject(Obj: TObject; Name: String);
  end;

  TzObjInspectorBase = class(TzCustomControl)
  private
    CanvasStack: TzCanvasStack;
    FComponent: TObject;
    FContext: TRttiContext;
    FRttiType: TRttiType;
    FComponentClassType: TClass;
    FItems: TPropList;
    FVisibleItems: TList<PPropItem>;
    FSaveVisibleItems: TList<String>;
    FExpandedList: TList<String>;
    FPropInstance: TDictionary<String, TObject>;
    FCategory: TList<String>;
    FPropsCategory: TDictionary<String, Integer>;
    FCircularLinkProps: TList<String>;
    FDefPropValue: TDictionary<String, String>;
    FOnBeforeAddItem: TPropItemEvent;
    FSortByCategory: Boolean;
    FDefaultCategoryName: String;
    FLockUpdate: Boolean;
    procedure SetComponent(Value: TObject);
    function GetItemOrder(PItem: PPropItem): Integer;
    procedure SetSortByCategory(const Value: Boolean);
  protected
    procedure UpdateVisibleItems;
    procedure UpdateItems;
    procedure ComponentChanged; virtual;
    procedure Changed; virtual;
  public
    procedure Invalidate;
    procedure BeginUpdate;
    procedure EndUpdate;
    function IsItemCircularLink(PItem: PPropItem): Boolean;
    function ItemNeedUpdate(PItem: PPropItem): Boolean;
    function NeedUpdate: Boolean;
    procedure ClearRegisteredCategorys;
    procedure RegisterPropertyInCategory(const CategoryName: string; const PropertyName: string);
    procedure UpdateProperties(const Repaint: Boolean = False); virtual;
    function IsValueNoDefault(QualifiedName: String; Value: String): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Component: TObject read FComponent write SetComponent;
    // property ComponentRoot: TCustomForm read GetComponentRoot;
    property ComponentClassType: TClass read FComponentClassType;
    property Items: TPropList read FItems;
    property VisibleItems: TList<PPropItem> read FVisibleItems;
    property SortByCategory: Boolean read FSortByCategory write SetSortByCategory;
    property DefaultCategoryName: String read FDefaultCategoryName write FDefaultCategoryName;
    property OnBeforeAddItem: TPropItemEvent read FOnBeforeAddItem write FOnBeforeAddItem;
  end;

  TzObjInspectorList = class(TzObjInspectorBase)
  private
    FItemHeight: Integer;
    FReadOnly: Boolean;
    FBorderStyle: TBorderStyle;
    procedure SetBorderStyle(const Value: TBorderStyle);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

  TzObjInspectorSizing = class(TzObjInspectorList)
  private
    FSplitterColor: TColor;
    FSplitterPos: Integer;
    FSplitterDown: Boolean;
    FFixedSplitter: Boolean;
    FOnSplitterPosChanged: TSplitterPosChangedEvent;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MouseMove;
    procedure SetSplitterPos(const Value: Integer);
    function GetSplitterRect: TRect;
    procedure SetSplitterColor(const Value: TColor);
  protected
    procedure InvalidateNC;
    procedure DrawSplitter(Canvas: TCanvas); virtual;
    procedure SplitterPosChanged(var Pos: Integer); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SplitterColor: TColor read FSplitterColor write SetSplitterColor;
    property SplitterPos: Integer read FSplitterPos write SetSplitterPos;
    property FixedSplitter: Boolean read FFixedSplitter write FFixedSplitter;
    property SplitterRect: TRect read GetSplitterRect;
    property OnSplitterPosChanged: TSplitterPosChangedEvent read FOnSplitterPosChanged write FOnSplitterPosChanged;
  end;

  TzObjInspectorHeader = class(TzObjInspectorSizing)
  private
    FShowHeader: Boolean;
    FHeaderPropText: String;
    FHeaderValueText: String;
    FHeaderPressed: Boolean;
    FHeaderPropPressed: Boolean;
    FHeaderValuePressed: Boolean;
    FOnHeaderMouseDown: THeaderMouseDownEvent;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    function GetHeaderRect: TRect;
    function GetHeaderPropRect: TRect;
    function GetHeaderValueRect: TRect;
    procedure SetShowHeader(const Value: Boolean);
    procedure SetHeaderPropText(const Value: String);
    procedure SetHeaderValueText(const Value: String);
  protected
    procedure Paint; override;
    procedure PaintHeader; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property HeaderRect: TRect read GetHeaderRect;
    property HeaderPropRect: TRect read GetHeaderPropRect;
    property HeaderValueRect: TRect read GetHeaderValueRect;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader;
    property OnHeaderMouseDown: THeaderMouseDownEvent read FOnHeaderMouseDown write FOnHeaderMouseDown;
    property HeaderPropText: String read FHeaderPropText write SetHeaderPropText;
    property HeaderValueText: String read FHeaderValueText write SetHeaderValueText;
  end;

  TzScrollObjInspectorList = class(TzObjInspectorHeader)
  private
    FSI: TScrollInfo;
    FPrevScrollPos: Integer;
    procedure CMFONTCHANGED(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMWINDOWPOSCHANGED(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMERASEBKGND(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    function IndexToVirtualIndex(Index: Integer): Integer;
    function GetFirstItemIndex: Integer;
    function GetLastItemIndex: Integer;
    function GetMaxItemCount: Integer;
    function GetItemTop(vIndex: Integer): Integer;
    function GetIndexFromPoint(Pt: TPoint): Integer;
  protected
    procedure UpdateScrollBar;
    procedure Paint; override;
    procedure PaintBkgnd(Canvas: TCanvas); virtual;
    function GetVisiblePropCount: Integer;
    procedure PaintItem(Index: Integer); virtual;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property VisiblePropCount: Integer read GetVisiblePropCount;
  end;

  TzCustomObjInspector = class(TzScrollObjInspectorList)
  private
    FPropInspEdit: TzPropInspEdit;
    FSelectedIndex: Integer;
    FSepTxtDis: Integer;
    FClickTime: Integer;
    FGutterWidth: Integer;
    FExtraRectIndex: Integer;
    FGutterColor: TColor;
    FGutterEdgeColor: TColor;
    FHighlightColor: TColor;
    FReferencesColor: TColor;
    FSubPropertiesColor: TColor;
    FValueColor: TColor;
    FReadOnlyColor: TColor;
    FNonDefaultValueColor: TColor;
    FBoldNonDefaultValue: Boolean;
    FNameColor: TColor;
    FShowGutter: Boolean;
    FShowGridLines: Boolean;
    FGridColor: TColor;
    FSelItem: TPropItem;
    FTrackChange: Boolean;
    FAutoCompleteText: Boolean;
    FOnGetItemReadOnly: TPropItemEvent;
    FOnSelectItem: TPropItemEvent;
    FOnItemSetValue: TItemSetValue;
    FOnExpandItem: TPropItemEvent;
    FOnCollapseItem: TPropItemEvent;
    FPropsNeedHint: Boolean;
    FValuesNeedHint: Boolean;
    FPrevHintIndex: Integer;
    FHintPoint: TPoint;
    FBoldHint: Boolean;
    FIsItemHint: Boolean;
    FShowItemHint: Boolean;
    FSearchText: String;
    FAllowSearch: Boolean;
    FCategoryColor: TColor;
    FCategoryTextColor: TColor;
    procedure CMSTYLECHANGED(var Message: TMessage); message CM_STYLECHANGED;
    procedure WMKILLFOCUS(var Msg: TWMKILLFOCUS); message WM_KILLFOCUS;
    procedure WMSETFOCUS(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLBUTTONDBLCLK(var Message: TWMLBUTTONDBLCLK); message WM_LBUTTONDBLCLK;
    function GetPlusMinBtnRect(Index: Integer): TRect;
    function GetItemRect(Index: Integer): TRect;
    function GetValueRect(Index: Integer): TRect;
    function GetPropTextRect(Index: Integer): TRect;
    function GetValueTextRect(Index: Integer): TRect;
    function GetExtraRect(Index: Integer): TRect;
    function CanDrawChevron(Index: Integer): Boolean;
    procedure SetGutterColor(const Value: TColor);
    procedure SetGutterEdgeColor(const Value: TColor);
    procedure SetHighlightColor(const Value: TColor);
    procedure SetReferencesColor(const Value: TColor);
    procedure SetSubPropertiesColor(const Value: TColor);
    procedure SetValueColor(const Value: TColor);
    procedure SetNameColor(const Value: TColor);
    procedure SetNonDefaultValueColor(const Value: TColor);
    procedure SetBoldNonDefaultValue(const Value: Boolean);
    procedure SetShowGutter(const Value: Boolean);
    procedure SetShowGridLines(const Value: Boolean);
    procedure SetGridColor(const Value: TColor);
    function GetSelectedItem: PPropItem;
    procedure SetGutterWidth(const Value: Integer);
    procedure SetAllowSearch(const Value: Boolean);
    procedure SetReadOnlyColor(const Value: TColor);
  protected
    procedure CreateWnd; override;
    procedure Paint; override;
    function DoSelectCaret(Index: Integer): Boolean;
    function DoSetValue(PropItem: PPropItem; var Value: TValue): Boolean;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WndProc(var Message: TMessage); override;
    procedure UpdateSelIndex;
    function DoExpandItem(PItem: PPropItem): Boolean;
    function DoCollapseItem(PItem: PPropItem): Boolean;
    procedure DoExtraRectClick;
    procedure UpdateEditControl(const SetValue: Boolean = True);
    procedure SplitterPosChanged(var Pos: Integer); override;
    procedure PaintItem(Index: Integer); override;
    procedure PaintCategory(Index: Integer); virtual;
    procedure PaintItemValue(PItem: PPropItem; Index: Integer); virtual;
  public
    function SetPropValue(PropItem: PPropItem; var Value: TValue): Boolean;
    /// <summary> Update the Inspector .
    /// </summary>
    /// <param name="Repaint"> if true , the Inspector will be repainted after updating .
    /// </param>
    procedure UpdateProperties(const Repaint: Boolean = False); override;
    procedure SelectItem(Index: Integer);
    procedure ExpandAll;
    procedure CollapseAll;
    function ExpandItem(PItem: PPropItem): Boolean;
    function CollapseItem(PItem: PPropItem): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property PlusMinBtnRect[Index: Integer]: TRect read GetPlusMinBtnRect;
    property PropTextRect[Index: Integer]: TRect read GetPropTextRect;
    property ValueTextRect[Index: Integer]: TRect read GetValueTextRect;
    property ItemRect[Index: Integer]: TRect read GetItemRect;
    property ValueRect[Index: Integer]: TRect read GetValueRect;
    property ExtraRect[Index: Integer]: TRect read GetExtraRect;
    property GutterColor: TColor read FGutterColor write SetGutterColor;
    property GutterEdgeColor: TColor read FGutterEdgeColor write SetGutterEdgeColor;
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor;
    property ReferencesColor: TColor read FReferencesColor write SetReferencesColor;
    property SubPropertiesColor: TColor read FSubPropertiesColor write SetSubPropertiesColor;
    property ValueColor: TColor read FValueColor write SetValueColor;
    property NonDefaultValueColor: TColor read FNonDefaultValueColor write SetNonDefaultValueColor;
    property BoldNonDefaultValue: Boolean read FBoldNonDefaultValue write SetBoldNonDefaultValue;
    property NameColor: TColor read FNameColor write SetNameColor;
    property ReadOnlyColor: TColor read FReadOnlyColor write SetReadOnlyColor;
    property ShowGutter: Boolean read FShowGutter write SetShowGutter;
    property ShowGridLines: Boolean read FShowGridLines write SetShowGridLines;
    property GridColor: TColor read FGridColor write SetGridColor;
    property SelectedItem: PPropItem read GetSelectedItem;
    property TrackChange: Boolean read FTrackChange write FTrackChange;
    property AutoCompleteText: Boolean read FAutoCompleteText write FAutoCompleteText;
    property GutterWidth: Integer read FGutterWidth write SetGutterWidth;
    property ShowItemHint: Boolean read FShowItemHint write FShowItemHint;
    property OnGetItemReadOnly: TPropItemEvent read FOnGetItemReadOnly write FOnGetItemReadOnly;
    property OnItemSetValue: TItemSetValue read FOnItemSetValue write FOnItemSetValue;
    property OnCollapseItem: TPropItemEvent read FOnCollapseItem write FOnCollapseItem;
    property OnExpandItem: TPropItemEvent read FOnExpandItem write FOnExpandItem;
    property OnSelectItem: TPropItemEvent read FOnSelectItem write FOnSelectItem;
    property AllowSearch: Boolean read FAllowSearch write SetAllowSearch;
  end;

  TzObjectInspector = class(TzCustomObjInspector)
  strict private
    class constructor Create;
    class destructor Destroy;
  published
    property Align;
    property Text;
    property Font;
    property Color;
    property BorderStyle;
    property Hint;
    property PopupMenu;
    property Component;
    property Ctl3d;
    property TabStop;
    property TabOrder;
    property AllowSearch;
    property AutoCompleteText;
    property DefaultCategoryName;
    property ShowGutter;
    property GutterColor;
    property GutterEdgeColor;
    property NameColor;
    property ValueColor;
    property NonDefaultValueColor;
    property BoldNonDefaultValue;
    property HighlightColor;
    property ReferencesColor;
    property SubPropertiesColor;
    property ShowHeader;
    property ShowGridLines;
    property GridColor;
    property SplitterColor;
    property FixedSplitter;
    property ReadOnly;
    property TrackChange;
    property GutterWidth;
    property ShowItemHint;
    property SortByCategory;
    property HeaderPropText;
    property HeaderValueText;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnBeforeAddItem;
    property OnGetItemReadOnly;
    property OnHeaderMouseDown;
    property OnSplitterPosChanged;
    property OnItemSetValue;
    property OnCollapseItem;
    property OnExpandItem;
    property OnSelectItem;
  end;

var
  DefaultValueManager: TzCustomValueManagerClass = TzCustomValueManager;

implementation

uses
  zObjInspList,
  zStringsDialog,
  zGraphicDialog;

resourcestring
  SDialogDerivedErr = 'Dialog must be derived from TCommonDialog or TzInspDialog';
  SInvalidPropValueErr = 'Invalid property value.';
  SOutOfRangeErr = 'Index out of range.';
  SSelNonVisibleItemErr = 'Could not select a non visible item.';

const

  PlusMinWidth = 10;
  ColorWidth = 12;

type
  InspException = class(Exception);
  DialogDerivedError = class(InspException);
  InvalidPropValueError = class(InspException);
  OutOfRangeError = class(InspException);

  { =============>Utils<============= }
function GetMethodName(Value: TValue; Obj: TObject): String;
begin
  Result := '';
  if (not Assigned(Obj)) or (Value.Kind <> tkMethod) or (Value.IsEmpty) then
    Exit;
  Result := Obj.MethodName(TValueData(Value).FAsMethod.Code);
end;

function PropSameMethodType(AProp: TRttiType; AMethod: TRttiMethod): Boolean;
var
  LPType: TRttiInvokableType;
  LPropParamsList, LMethodParamsList: TArray<TRttiParameter>;
  LSPropParamType, LSMethodParamType: String;
  LPropParam, LMethodParam: TRttiParameter;
  L, i: Integer;
begin
  Result := False;
  if AProp is TRttiMethodType then
    if TRttiMethodType(AProp).MethodKind <> AMethod.MethodKind then
      Exit;
  if AProp is TRttiMethodType then
  begin
    LPType := TRttiInvokableType(AProp);
    { Check if had same method type ( Procedure or function) }
    Result := (AMethod.ReturnType = nil) and (LPType.ReturnType = nil);
    if not Result then
    begin
      Result := Assigned(AMethod.ReturnType);
      if not Result then
        Exit;
      Result := Assigned(LPType.ReturnType);
      if not Result then
        Exit;
      { Check if had same ReturnType if its a function }
      Result := LPType.ReturnType.Handle = AMethod.Handle;
      if not Result then
        Exit;
    end;
    { Check if had same Calling Convention }
    Result := AMethod.CallingConvention = LPType.CallingConvention;
    if not Result then
      Exit;

    { Check if had same parameters }
    LMethodParamsList := AMethod.GetParameters;
    LPropParamsList := LPType.GetParameters;
    Result := Length(LMethodParamsList) = Length(LPropParamsList);
    if not Result then
      Exit;
    L := Length(LMethodParamsList);
    for i := 0 to L - 1 do
    begin
      LSPropParamType := '';
      LSMethodParamType := '';
      LPropParam := LPropParamsList[i];
      LMethodParam := LMethodParamsList[i];
      if not SameText(LMethodParam.Name, LPropParam.Name) then
        Exit(False);
      if Assigned(LPropParam.ParamType) then
        LSPropParamType := LPropParam.ParamType.ToString;
      if Assigned(LMethodParam.ParamType) then
        LSMethodParamType := LMethodParam.ParamType.ToString;
      if not SameText(LSPropParamType, LSMethodParamType) then
        Exit(False);
    end;
  end;
end;

function IsClassDerivedFromClass(const AClassType: TClass; BaseClass: TClass): Boolean;
var
  C: TClass;
begin
  Result := False;
  C := AClassType;
  while C <> nil do
  begin
    if C = BaseClass then
      Exit(True);
    C := C.ClassParent;
  end;
end;

function IsPropTypeDerivedFromClass(const PropType: TRttiType; BaseClass: TClass): Boolean;
var
  T: TRttiType;
begin
  Result := False;

  if PropType.TypeKind <> tkClass then
    Exit;
  T := PropType;
  while T <> nil do
  begin
    if T.Handle = PTypeInfo(BaseClass.ClassInfo) then
      Exit(True);
    T := T.BaseType; // Parent base class .
  end;
end;

function ObjHasAtLeastOneChild(Obj: TObject): Boolean;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LPropList: TArray<TRttiProperty>;
  LProp: TRttiProperty;
begin
  Result := False;
  if not Assigned(Obj) then
    Exit;
  LCtx := TRttiContext.Create;
  LType := LCtx.GetType(Obj.ClassInfo);
  LPropList := TzRttiType(LType).GetUsedProperties;
  for LProp in LPropList do
    if LProp.Visibility = mvPublished then
      Exit(True);
end;

function GetEnumOrdValue(const Value: TValue): Integer;
var
  vd: TValueData;
begin
  Result := 0;
  vd := TValueData(Value);
  case Value.TypeData.OrdType of
    otSByte:
      Result := vd.FAsSByte;
    otUByte:
      Result := vd.FAsUByte;
    otSWord:
      Result := vd.FAsSWord;
    otUWord:
      Result := vd.FAsUWord;
    otSLong:
      Result := vd.FAsSLong;
    otULong:
      Result := vd.FAsULong;
  end;
end;

function IsValueSigned(const Value: TValue): Boolean;
begin
  Result := (Value.TypeData.MinValue < 0) or (Value.TypeData.MinInt64Value < 0);
end;

function SetEnumToBoolean(SetValue, Value: Integer): Boolean;
var
  s: TIntegerSet;
begin
  Integer(s) := SetValue;
  Result := Value in s;
end;

function BooleanToStr(B: Boolean): string;
const
  BoolStrs: array [Boolean] of String = ('False', 'True');
begin
  Result := BoolStrs[B];
end;

function GetFormRoot(Comp: TObject): TCustomForm;
begin
  Result := nil;
  if Comp is TCustomForm then
    Result := TCustomForm(Comp)
  else if Comp is TControl then
    Result := GetParentForm(TControl(Comp));
end;

{ TPropList }

procedure TPropList.FreeRecord(P: Pointer);
begin
  inherited;
end;

function TPropList.IndexOfQName(QName: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  if Count > 0 then
    for i := 0 to Count - 1 do
      if SameText(Items[i].FQName, QName) then
        Exit(i);
end;

procedure TPropList.Sort;
  function Compare(Item1, Item2: Pointer): Integer;
  begin
    Result := CompareText(PPropItem(Item1).FQName, PPropItem(Item2).FQName);
  end;

begin
  FList.Sort(@Compare);
end;

{ TPropItem }

procedure TPropItem.CheckItemsList;
begin
  if not Assigned(FItems) then
    raise InspException.Create('Items list cannot be nil.');
end;

class function TPropItem.Empty: TPropItem;
begin
  ZeroMemory(@Result, SizeOf(TPropItem));
end;

function TPropItem.EqualTo(A: PPropItem): Boolean;
begin
  Result := @Self = A;
end;

function TPropItem.GetComponentRoot: TCustomForm;
begin
  Result := GetFormRoot(Component);
end;

function TPropItem.GetCount: Integer;
var
  L: Integer;
  i: Integer;
  P: PPropItem;
begin
  CheckItemsList;
  Result := 0;
  if not MayHaveChild then
    Exit;
  L := FItems.IndexOf(@Self);
  if L > -1 then
  begin
    for i := L + 1 to FItems.Count - 1 do
    begin
      P := FItems.Items[i];
      if IsCategory then
      begin
        if CategoryIndex = P.CategoryIndex then
          Inc(Result)
        else if P.CategoryIndex > -1 then
          Break;
      end
      else
      begin
        if P.Parent = @Self then
          Inc(Result);
        if Parent = P.Parent then
          Break;
      end;
    end;
  end;
end;

function TPropItem.GetExpanded: Boolean;
begin
  CheckItemsList;
  Result := Count > 0;
  if Result then
    Result := Assigned(Items[0]);
  if Result then
    Result := Items[0].FVisible;
end;

function TPropItem.GetHasChild: Boolean;
begin
  if IsCategory then
    Exit(True);
  if not MayHaveChild then
    Exit(False);
  Result := not Value.IsEmpty;
  if Result and IsClass then
    Result := ObjHasAtLeastOneChild(Value.AsObject);
end;

function TPropItem.GetDynInstance: TObject;
var
  LInsp: TzObjInspectorBase;
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LObj: TObject;
  LValue: TValue;
  LList: TList;
  i: Integer;
  procedure GetParents;
  var
    P: PPropItem;
  begin
    P := Parent;
    while Assigned(P) do
    begin
      LList.Add(P);
      P := P.Parent;
    end;
  end;

begin
  CheckItemsList;
  LInsp := TzObjInspectorBase(Insp);
  LObj := Component;
  LCtx := TRttiContext.Create;
  LList := TList.Create;
  GetParents;
  Result := LObj;
  for i := LList.Count - 1 downto 0 do
  begin
    if not Assigned(LObj) then
    begin
      LList.Free;
      Exit(nil);
    end;
    LType := LCtx.GetType(LObj.ClassInfo);
    LProp := LType.GetProperty(PPropItem(LList.Items[i]).Name);
    LValue := LProp.GetValue(LObj);
    if LValue.IsObject then
      LObj := LValue.AsObject;
    if LProp = Parent.Prop then
    begin
      Result := LObj;
      Break;
    end;
  end;
  LList.Free;
end;

function TPropItem.GetItem(const Index: Integer): PPropItem;
var
  L, J, CC, i: Integer;
  LList: TList;
begin
  CheckItemsList;
  Result := nil;

  if not(IsCategory or IsClass or IsSet) then
    Exit;
  LList := TList.Create;
  L := FItems.IndexOf(@Self);
  J := 0;
  if L > -1 then
  begin
    CC := Count; // Childs count.
    for i := L + 1 to FItems.Count - 1 do
    begin
      if IsCategory then
      begin
        if FItems.Items[i].CategoryIndex = CategoryIndex then
        begin
          Inc(J);
          LList.Add(FItems.Items[i]);
        end;
      end
      else if FItems.Items[i].Parent = @Self then
      begin
        Inc(J);
        LList.Add(FItems.Items[i]);
      end;
      if J = CC then
        Break;
    end;
  end;
  Result := LList.Items[Index];
  LList.Free;
end;

function TPropItem.GetName: String;
begin

  if IsCategory then
  begin
    Result := TzObjInspectorBase(Insp).FCategory[CategoryIndex];
    Exit;
  end;
  if IsSetElement then
    Result := GetEnumName(Prop.PropertyType.AsSet.ElementType.Handle, SetElementValue)
  else
    Result := Prop.Name;
end;

function TPropItem.GetValue: TValue;
var
  LInstance: TObject;
begin
  Result := TValue.Empty;
  if IsCategory then
    Exit();
  LInstance := Instance;
  if Assigned(LInstance) then
    Result := Prop.GetValue(LInstance);
end;

function TPropItem.GetValueName: String;
begin
  Result := DefaultValueManager.GetValueName(@Self);
end;

function TPropItem.GetVisible: Boolean;
begin
  Result := FVisible;
  if Result then
    Result := Assigned(Instance);
end;

function TPropItem.IsCategory: Boolean;
begin
  Result := FIsCategory;
end;

function TPropItem.IsClass: Boolean;
begin
  if not Assigned(Prop) then
    Exit(False);
  if IsCategory then
    Exit(False);
  Result := Prop.PropertyType.TypeKind = tkClass;
end;

function TPropItem.IsEmpty: Boolean;
var
  P: TPropItem;
begin
  P := TPropItem.Empty;
  Result := CompareMem(@Self, @P, SizeOf(TPropItem));
end;

function TPropItem.IsEnum: Boolean;
begin
  if IsCategory then
    Exit(False);
  Result := Prop.PropertyType.TypeKind = tkEnumeration;
end;

function TPropItem.IsSet: Boolean;
begin
  if not Assigned(Prop) then
    Exit(False);
  if IsCategory then
    Exit(False);
  Result := (Prop.PropertyType.TypeKind = tkSet) and (SetElementValue = -1);
end;

function TPropItem.IsSetElement: Boolean;
begin
  if not Assigned(Prop) then
    Exit(False);
  if IsCategory then
    Exit(False);
  Result := (Prop.PropertyType.TypeKind = tkSet) and (SetElementValue > -1);
end;

function TPropItem.MayHaveChild: Boolean;
begin
  Result := IsCategory or IsClass or IsSet;
end;

{ TzObjInspectorBase }
constructor TzObjInspectorBase.Create(AOwner: TComponent);
begin
  inherited;
  FLockUpdate := False;
  CanvasStack := TzCanvasStack.Create();
  ControlStyle := ControlStyle - [csAcceptsControls];
  FContext := TRttiContext.Create;
  FItems := TPropList.Create;
  FVisibleItems := TList<PPropItem>.Create;
  FExpandedList := TList<String>.Create;
  FSaveVisibleItems := TList<String>.Create;
  FCircularLinkProps := TList<String>.Create;
  FDefPropValue := TDictionary<String, String>.Create;
  FCategory := TList<String>.Create;
  FPropsCategory := TDictionary<String, Integer>.Create;
  FPropInstance := TDictionary<String, TObject>.Create;
  FDefaultCategoryName := 'Miscellaneous';
  FSortByCategory := False;
  FOnBeforeAddItem := nil;
  FComponent := nil;
  DefaultValueManager := DefaultValueManager;
end;

destructor TzObjInspectorBase.Destroy;
begin
  CanvasStack.Free;
  if Assigned(FExpandedList) then
    FreeAndNil(FExpandedList);
  if Assigned(FPropInstance) then
    FreeAndNil(FPropInstance);
  if Assigned(FCategory) then
    FreeAndNil(FCategory);
  if Assigned(FPropsCategory) then
    FreeAndNil(FPropsCategory);
  if Assigned(FItems) then
    FreeAndNil(FItems);
  if Assigned(FVisibleItems) then
    FreeAndNil(FVisibleItems);
  if Assigned(FSaveVisibleItems) then
    FreeAndNil(FSaveVisibleItems);
  if Assigned(FCircularLinkProps) then
    FreeAndNil(FCircularLinkProps);
  if Assigned(FDefPropValue) then
    FreeAndNil(FDefPropValue);
  FContext.Free;
  inherited;
end;

procedure TzObjInspectorBase.EndUpdate;
begin
  if FLockUpdate then
  begin
    FLockUpdate := False;
    Invalidate;
  end;
end;

function TzObjInspectorBase.GetItemOrder(PItem: PPropItem): Integer;
var
  i: Integer;
  s: string;
begin
  { Return the Item order . }
  Result := 0;
  s := PItem.FQName;
  i := Pos('.', s);
  if i <= 0 then
    Exit;
  while i > 0 do
  begin
    Inc(Result);
    i := Pos('.', s, i + 1);
  end;
  Dec(Result);
  if FSortByCategory then
    Dec(Result);
  if PItem.CategoryIndex > -1 then
    Result := 0;
end;

procedure TzObjInspectorBase.Invalidate;
begin
  if not FLockUpdate then
  begin
    CanvasStack.Clear;
    CanvasStack.TrimExcess;
    inherited Invalidate;
  end;
end;

function TzObjInspectorBase.IsItemCircularLink(PItem: PPropItem): Boolean;
begin
  Result := FCircularLinkProps.Contains(PItem.QualifiedName);
end;

function TzObjInspectorBase.IsValueNoDefault(QualifiedName, Value: String): Boolean;
begin
  Result := False;
  if FDefPropValue.ContainsKey(QualifiedName) then
    Result := FDefPropValue[QualifiedName] <> Value;
end;

function TzObjInspectorBase.ItemNeedUpdate(PItem: PPropItem): Boolean;
var
  P: PPropItem;
begin
  { Item will need update if its instance was changed
    or the instances of it's parents !
  }
  Result := False;
  if PItem.IsClass then
    if FPropInstance.ContainsKey(PItem.QualifiedName) then
      if FPropInstance[PItem.QualifiedName] <> PItem.Value.AsObject then
        Exit(True);

  P := PItem.Parent;
  while Assigned(P) do
  begin
    if P.IsClass then
      if FPropInstance.ContainsKey(P.QualifiedName) then
        if FPropInstance[P.QualifiedName] <> P.Value.AsObject then
          Exit(True);
    P := P.Parent;
  end;
end;

function TzObjInspectorBase.NeedUpdate: Boolean;
var
  i: Integer;
  PItem: PPropItem;
begin
  Result := False;
  for i := 0 to FVisibleItems.Count - 1 do
  begin
    PItem := FVisibleItems[i];
    if ItemNeedUpdate(PItem) then
      Exit(True);
  end;
end;

procedure TzObjInspectorBase.RegisterPropertyInCategory(const CategoryName: string; const PropertyName: string);
var
  L: Integer;
begin
  L := FCategory.IndexOf(CategoryName);
  if L < 0 then
    L := FCategory.Add(CategoryName);
  if not FPropsCategory.ContainsKey(PropertyName) then
    FPropsCategory.Add(PropertyName, L);
end;

procedure TzObjInspectorBase.BeginUpdate;
begin
  FLockUpdate := True;
end;

procedure TzObjInspectorBase.Changed;
begin
  UpdateProperties(True);
end;

procedure TzObjInspectorBase.ClearRegisteredCategorys;
begin
  FCategory.Clear;
  FPropsCategory.Clear;
  FCategory.Add(FDefaultCategoryName);
  UpdateProperties(True);
end;

procedure TzObjInspectorBase.ComponentChanged;
begin
  FCategory.Clear;
  FCategory.Add(FDefaultCategoryName);
  FPropsCategory.Clear;
  FDefPropValue.Clear;
  FCircularLinkProps.Clear;
  FItems.Clear;
  FVisibleItems.Clear;
  FSaveVisibleItems.Clear;
  FExpandedList.Clear;
  FComponentClassType := nil;
  if Assigned(FComponent) then
  begin
    FRttiType := FContext.GetType(FComponent.ClassInfo);
    FComponentClassType := TRttiInstanceType(FRttiType).MetaclassType;
  end;
  Changed;
end;

procedure TzObjInspectorBase.SetComponent(Value: TObject);
begin
  if Value <> FComponent then
  begin
    if Assigned(FComponent) and (FComponent is TzObjectHost) then
      FreeAndNil(FComponent);
    FComponent := Value;
    ComponentChanged;
  end;
end;

procedure TzObjInspectorBase.SetSortByCategory(const Value: Boolean);
begin
  if FSortByCategory <> Value then
  begin
    FSortByCategory := Value;
    UpdateProperties(True);
  end;
end;

procedure TzObjInspectorBase.UpdateItems;
var
  LCategory: TList<String>;
  LObjHost: TzObjectHost;
  i: Integer;
  LComponent: TObject;
  LComponentName: String;
  LMultiInstance: Boolean;

  function IsCircularLink(P: Pointer; QType: String): Boolean;
  var
    LCtx: TRttiContext;
    LType: TRttiType;
    LPropList: TArray<TRttiProperty>;
    LProp: TRttiProperty;
    q, s: string;
    n, J: Integer;
  begin
    { This function return true if a ParentClass has
      a ChildClass that have a property to its parent.
      => Avoid infinite loop !

      eg:

      TParent = class
      published property Child:TChild ;
      end;

      TChild = class
      published property Parent:TParent ;
      end;
    }
    Result := False;
    LCtx := LCtx.Create;
    LType := LCtx.GetType(P);
    (* n := Pos('.', QType);
      j := n;
      while n > 0 do
      begin
      n := Pos('.', QType, n + 1);
      if n > 0 then
      j := n;
      end;
      Q := Copy(QType, 1, j - 1);
    *)

    s := LType.ToString;
    n := Pos(s, QType);
    q := Copy(QType, n + Length(s), Length(QType));
    { Allow adding others property and even the first
      circular child property. }
    if q = '' then
      Exit(False);
    LPropList := TzRttiType(LType).GetUsedProperties;
    for LProp in LPropList do
      if LProp.Visibility = mvPublished then
        if (LProp.PropertyType.TypeKind = tkClass) then
        begin
          s := LProp.PropertyType.ToString;
          if Pos(s, q) > 0 then
            Exit(True); // Circular link !
        end;

  end;

  procedure EnumProps(AInstance: TObject; AParent, ACategory: PPropItem; QualifiedName, QualifiedType: string);
  var
    LPropList: TArray<TRttiProperty>;
    LProp: TRttiProperty;
    LQName, LQType: String;
    Allow: Boolean;
    PItem: PPropItem;
    LInstance: TObject;
    L: Integer;
    LCategoryName: String;
    PCategory: PPropItem;
    function AddNewCategory: PPropItem;
    begin
      Result := FItems.Add;
      Result.FQName := LCategoryName + '.';
      Result.Component := LComponent;
      Result.FIsCategory := True;
      Result.Prop := nil;
      Result.Insp := Self;
      Result.FItems := FItems;
      Result.FVisible := True;
      Result.SetElementValue := -1;
      Result.Instance := nil;
      Result.Parent := nil;
      Result.CategoryIndex := L;
    end;
    procedure EnumSet;
    var
      P: PTypeInfo;
      LType: TRttiType;
      i: Integer;
      PSet: PPropItem;
    begin
      P := PTypeInfo(PItem.Prop.PropertyType.AsSet.ElementType.Handle);
      LType := FContext.GetType(P);
      for i := LType.AsOrdinal.MinValue to LType.AsOrdinal.MaxValue do
      begin
        PSet := FItems.Add;
        PSet.Component := LComponent;
        PSet.CategoryIndex := -1;
        PSet.FIsCategory := False;
        PSet.FItems := FItems;
        PSet.Prop := LProp;
        PSet.Instance := AInstance;
        PSet.FVisible := False;
        PSet.Insp := Self;
        PSet.Parent := PItem;
        PSet.SetElementValue := i;
        PSet.FQName := LQName + '.' + IntToStr(i);
      end;
    end;

  begin
    if not Assigned(AInstance) then
      Exit;
    FRttiType := FContext.GetType(AInstance.ClassInfo);
    LPropList := TzRttiType(FRttiType).GetUsedProperties;
    for LProp in LPropList do
      if LProp.Visibility = mvPublished then
      begin
        Allow := True;
        LQName := QualifiedName + '.' + LProp.Name;
        LQType := QualifiedType + '.' + LProp.PropertyType.ToString;
        L := -1;
        PCategory := ACategory;
        if (LMultiInstance) and (LComponent <> nil) and (AInstance = LComponent) then
        begin
          LCategoryName := LComponentName;
          if FCategory.Contains(LCategoryName) then
            L := FCategory.IndexOf(LCategoryName)
          else
          begin
            L := FCategory.Add(LCategoryName);
            PCategory := AddNewCategory;
          end;
        end
        else
        begin
          if FSortByCategory and (AInstance = LComponent) then
          begin
            if FPropsCategory.ContainsKey(LProp.Name) then
            begin
              L := FPropsCategory[LProp.Name];
              LCategoryName := FCategory[L];
              LQName := LCategoryName + '.' + LQName;
            end
            else
            begin
              LCategoryName := FDefaultCategoryName;
              L := 0;
              LQName := LCategoryName + '.' + LQName;
            end;
            if not LCategory.Contains(LCategoryName) then
            begin
              LCategory.Add(LCategoryName);
              PCategory := AddNewCategory;
            end;
          end;
        end;
        PItem := FItems.Add;
        PItem.FItems := FItems;
        if (AInstance <> LComponent) then
          L := -1;
        PItem.Component := LComponent;
        PItem.CategoryIndex := L;
        PItem.Instance := AInstance;
        PItem.FIsCategory := False;
        PItem.SetElementValue := -1;
        PItem.Insp := Self;
        PItem.Parent := AParent;
        PItem.Prop := LProp;
        PItem.FQName := LQName;
        if FSortByCategory then
          PItem.FVisible := False
        else
          PItem.FVisible := AParent = nil;
        if Assigned(FOnBeforeAddItem) then
          Allow := FOnBeforeAddItem(Self, PItem);
        if not Allow then
          FItems.Delete(FItems.Count - 1);
        if Allow then
        begin
          if PItem.IsClass then
          begin
            LInstance := nil;
            if not PItem.Value.IsEmpty then
              LInstance := PItem.Value.AsObject;
            if Assigned(LInstance) then
              if not IsCircularLink(LInstance.ClassInfo, LQType) then
                EnumProps(LInstance, PItem, PCategory, PItem.FQName, LQType)
              else
                FCircularLinkProps.Add(LQName);
            FPropInstance.Add(LQName, LInstance);
          end
          else if (PItem.IsSet) then
          begin
            EnumSet;
          end;
        end;
      end;
  end;

begin
  FItems.Clear;
  FCircularLinkProps.Clear;
  FPropInstance.Clear;
  if not Assigned(FComponent) then
    Exit;
  LCategory := TList<String>.Create;
  LMultiInstance := False;
  LComponent := FComponent;
  if FComponent is TzObjectHost then
  begin
    LObjHost := TzObjectHost(FComponent);
    FSortByCategory := True;
    LMultiInstance := True;
    FCategory.Clear;
    FPropsCategory.Clear;
    for i := 0 to LObjHost.FList.Count - 1 do
    begin
      LComponent := LObjHost.FList[i].Key;
      LComponentName := LObjHost.FList[i].Value;
      EnumProps(LComponent, nil, nil, LComponentName + '.' + LComponent.ToString, LComponent.ToString);
    end;
  end
  else
    EnumProps(FComponent, nil, nil, FComponent.ToString, FComponent.ToString);
  FItems.Sort;
  LCategory.Free;
end;

procedure TzObjInspectorBase.UpdateProperties(const Repaint: Boolean);
begin

end;

procedure TzObjInspectorBase.UpdateVisibleItems;
var
  i: Integer;
  PItem: PPropItem;
  LVisible: Boolean;
  procedure MakeChildsVisible(PParent: PPropItem; Visible: Boolean);
  var
    J: Integer;
  begin
    for J := 0 to PParent.Count - 1 do
    begin
      PParent.Items[J].FVisible := Visible;
      // FVisibleItems.Add(PParent.Items[J]);
    end;
  end;
  procedure MakeVisible(AItem: PPropItem; Visible: Boolean);
  begin
    AItem.FVisible := Visible;
    if Visible then
      FVisibleItems.Add(AItem);
  end;
  function IsAllParentVisible(AItem: PPropItem): Boolean;
  var
    P: PPropItem;
  begin
    Result := False;
    P := AItem.Parent;
    while Assigned(P) do
    begin
      if not FExpandedList.Contains(P.QualifiedName) then
        Exit(False);
      P := P.Parent;
    end;
    Result := True;
  end;

begin
  FVisibleItems.Clear;

  for i := 0 to FItems.Count - 1 do
  begin
    PItem := FItems.Items[i];
    if PItem.IsCategory then
    begin
      if FExpandedList.Contains(PItem.QualifiedName) then
        MakeChildsVisible(PItem, True);
    end;
    LVisible := PItem.FVisible;
    if LVisible then
      MakeVisible(PItem, True)
    else if FSaveVisibleItems.Contains(PItem.QualifiedName) then
      MakeVisible(PItem, True)

  end;

end;

{ TzObjInspectorList }

constructor TzObjInspectorList.Create(AOwner: TComponent);
begin
  inherited;
  Width := 300;
  Height := 300;
  FBorderStyle := bsSingle;
  FReadOnly := False;
  FItemHeight := 17;
end;

procedure TzObjInspectorList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if FBorderStyle <> bsNone then
    Params.Style := Params.Style or WS_BORDER;
end;

destructor TzObjInspectorList.Destroy;
begin

  inherited;
end;

procedure TzObjInspectorList.SetBorderStyle(const Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

{ TzObjInspectorSizing }

constructor TzObjInspectorSizing.Create(AOwner: TComponent);
begin
  inherited;
  FOnSplitterPosChanged := nil;
  Color := clWhite;
  FFixedSplitter := False;
  FSplitterDown := False;
  FSplitterColor := clGray;
  FSplitterPos := 100;
end;

destructor TzObjInspectorSizing.Destroy;
begin

  inherited;
end;

procedure TzObjInspectorSizing.DrawSplitter(Canvas: TCanvas);
var
  LColor: TColor;
begin
  Canvas.Refresh;
  LColor := FSplitterColor;
  if UseStyleColor then
    LColor := StyleServices.GetStyleColor(scSplitter);
  Canvas.Pen.Color := LColor;
  Canvas.MoveTo(FSplitterPos, 0);
  Canvas.LineTo(FSplitterPos, Height);
end;

function TzObjInspectorSizing.GetSplitterRect: TRect;
begin
  Result := Rect(FSplitterPos - 5, 0, FSplitterPos + 5, Height);
end;

procedure TzObjInspectorSizing.InvalidateNC;
begin
  if HandleAllocated and not FLockUpdate then
    SendMessage(Handle, WM_NCPAINT, 0, 0);
end;

procedure TzObjInspectorSizing.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  FSplitterDown := False;
  if FFixedSplitter then
    Exit;

  GetCursorPos(P);
  P := ScreenToClient(P);
  P.Y := 0;
  if SplitterRect.Contains(P) then
    FSplitterDown := True;
end;

procedure TzObjInspectorSizing.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  FSplitterDown := False;
  if FFixedSplitter then
    Exit;
end;

procedure TzObjInspectorSizing.Paint;
begin
  inherited;
  DrawSplitter(Canvas);
end;

procedure TzObjInspectorSizing.SetSplitterColor(const Value: TColor);
begin
  if Value <> FSplitterColor then
  begin
    FSplitterColor := Value;
    Invalidate;
  end;
end;

procedure TzObjInspectorSizing.SetSplitterPos(const Value: Integer);
begin
  FSplitterPos := Value;
end;

procedure TzObjInspectorSizing.SplitterPosChanged(var Pos: Integer);
begin
  if Assigned(FOnSplitterPosChanged) then
    FOnSplitterPosChanged(Self, Pos);
end;

procedure TzObjInspectorSizing.WMMouseMove(var Message: TWMMouseMove);
var
  P: TPoint;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  if FFixedSplitter then
    Exit;
  P.X := Message.XPos;
  P.Y := Message.YPos;
  if SplitterRect.Contains(P) then
    Cursor := crHSplit
  else
    Cursor := crArrow;
  if FSplitterDown then
  begin
    if (P.X <> FSplitterPos) and (P.X > 10) and (P.X < ClientWidth - 10) then
    begin
      FSplitterPos := P.X;
      SplitterPosChanged(FSplitterPos);
      Invalidate;
    end;
  end;
end;

{ TzObjInspectorHeader }

constructor TzObjInspectorHeader.Create(AOwner: TComponent);
begin
  inherited;
  FOnHeaderMouseDown := nil;
  FHeaderPressed := False;
  FHeaderPropPressed := False;
  FHeaderValuePressed := False;
  FHeaderPropText := 'Property';
  FHeaderValueText := 'Value';
  FShowHeader := False;
end;

function TzObjInspectorHeader.GetHeaderPropRect: TRect;
begin
  Result := Rect(0, 0, FSplitterPos, HeaderRect.Height);
end;

function TzObjInspectorHeader.GetHeaderRect: TRect;
begin
  Result := Rect(0, 0, Width, FItemHeight + (FItemHeight div 2));
end;

function TzObjInspectorHeader.GetHeaderValueRect: TRect;
begin
  Result := Rect(FSplitterPos, 0, Width, HeaderRect.Height);
end;

procedure TzObjInspectorHeader.Paint;
begin
  if FShowHeader then
    PaintHeader;
  inherited;
end;

procedure TzObjInspectorHeader.PaintHeader;
var
  LDetails: TThemedElementDetails;
  R: TRect;
begin
  CanvasStack.Push(Canvas);
  if FHeaderPropPressed then
    LDetails := StyleServices.GetElementDetails(thHeaderItemPressed)
  else
    LDetails := StyleServices.GetElementDetails(thHeaderItemNormal);;

  StyleServices.DrawElement(Canvas.Handle, LDetails, HeaderPropRect);
  R := HeaderPropRect;
  Inc(R.Left, 10);
  StyleServices.DrawText(Canvas.Handle, LDetails, FHeaderPropText, R, DT_LEFT or DT_SINGLELINE or DT_VCENTER, 0);

  if FHeaderValuePressed then
    LDetails := StyleServices.GetElementDetails(thHeaderItemPressed)
  else
    LDetails := StyleServices.GetElementDetails(thHeaderItemNormal);;

  StyleServices.DrawElement(Canvas.Handle, LDetails, HeaderValueRect);
  R := HeaderValueRect;
  Inc(R.Left, 10);
  StyleServices.DrawText(Canvas.Handle, LDetails, FHeaderValueText, R, DT_LEFT or DT_SINGLELINE or DT_VCENTER, 0);

  CanvasStack.Pop;
end;

procedure TzObjInspectorHeader.SetHeaderPropText(const Value: String);
begin
  if FHeaderPropText <> Value then
  begin
    FHeaderPropText := Value;
    Invalidate;
  end;
end;

procedure TzObjInspectorHeader.SetHeaderValueText(const Value: String);
begin
  if FHeaderValueText <> Value then
  begin
    FHeaderValueText := Value;
    Invalidate;
  end;
end;

procedure TzObjInspectorHeader.SetShowHeader(const Value: Boolean);
begin
  if FShowHeader <> Value then
  begin
    FShowHeader := Value;
    Invalidate;
  end;
end;

procedure TzObjInspectorHeader.WMLButtonDown(var Message: TWMLButtonDown);
var
  Pt: TPoint;
begin
  inherited;
  if not FShowHeader then
    Exit;
  Pt := Point(Message.XPos, Message.YPos);
  if SplitterRect.Contains(Pt) then
    Exit;
  if HeaderRect.Contains(Pt) then
  begin
    if not FHeaderPressed then
    begin
      FHeaderPropPressed := HeaderPropRect.Contains(Pt);
      FHeaderValuePressed := HeaderValueRect.Contains(Pt);
      FHeaderPressed := True;
      Invalidate;
    end;
    if Assigned(FOnHeaderMouseDown) then
    begin
      if FHeaderPropPressed then
        FOnHeaderMouseDown(Self, hiProp, Pt.X, Pt.Y)
      else if FHeaderValuePressed then
        FOnHeaderMouseDown(Self, hiVal, Pt.X, Pt.Y)
    end;
  end;
end;

procedure TzObjInspectorHeader.WMLButtonUp(var Message: TWMLButtonUp);
var
  Pt: TPoint;
begin
  inherited;
  if not FShowHeader then
    Exit;
  Pt := Point(Message.XPos, Message.YPos);
  if HeaderRect.Contains(Pt) then
  begin
    if FHeaderPressed then
    begin
      FHeaderPropPressed := False;
      FHeaderValuePressed := False;
      FHeaderPressed := False;
      Invalidate;
    end;
  end;
end;

{ TzScrollObjInspectorList }

procedure TzScrollObjInspectorList.CMFONTCHANGED(var Message: TMessage);
begin
  inherited;
  Canvas.Font.Assign(Font);
  FItemHeight := Canvas.TextHeight('WA') + 4; // 17;
end;

constructor TzScrollObjInspectorList.Create(AOwner: TComponent);
begin
  inherited;
  FPrevScrollPos := 0;
end;

procedure TzScrollObjInspectorList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_VSCROLL;
end;

destructor TzScrollObjInspectorList.Destroy;
begin

  inherited;
end;

function TzScrollObjInspectorList.GetFirstItemIndex: Integer;
begin
  FSI.cbSize := SizeOf(FSI);
  FSI.fMask := SIF_POS;
  GetScrollInfo(Handle, SB_VERT, FSI);
  Result := max(0, FSI.nPos);
end;

function TzScrollObjInspectorList.GetIndexFromPoint(Pt: TPoint): Integer;
var
  R: TRect;
  MaxItemCount, i, Y: Integer;
begin
  Result := -1;
  MaxItemCount := GetMaxItemCount;
  for i := 0 to MaxItemCount do
  begin
    Y := GetItemTop(i);
    R := Rect(0, Y, Width, Y + FItemHeight);
    if R.Contains(Pt) then
    begin
      Result := (i + GetFirstItemIndex);
      if (Result >= FVisibleItems.Count) then
        Exit(-1);
      Exit;
    end;
  end;
end;

function TzScrollObjInspectorList.GetItemTop(vIndex: Integer): Integer;
begin
  Result := vIndex * FItemHeight;
  if FShowHeader then
    Inc(Result, HeaderRect.Height);
end;

function TzScrollObjInspectorList.GetLastItemIndex: Integer;
begin
  FSI.cbSize := SizeOf(FSI);
  FSI.fMask := SIF_POS;
  GetScrollInfo(Handle, SB_VERT, FSI);
  Result := min(VisiblePropCount - 1, FSI.nPos + GetMaxItemCount);
end;

function TzScrollObjInspectorList.GetMaxItemCount: Integer;
var
  LHeight: Integer;
begin
  LHeight := Height;
  if FShowHeader then
    Dec(LHeight, HeaderRect.Height);
  Result := LHeight div FItemHeight;
end;

function TzScrollObjInspectorList.GetVisiblePropCount: Integer;
begin
  Result := FVisibleItems.Count;
end;

function TzScrollObjInspectorList.IndexToVirtualIndex(Index: Integer): Integer;
begin
  Result := Index - GetFirstItemIndex;
end;

procedure TzScrollObjInspectorList.Paint;
var
  i: Integer;
  FirstItem: Integer;
  LastItem: Integer;
begin
  PaintBkgnd(Canvas);
  FirstItem := GetFirstItemIndex;
  LastItem := GetLastItemIndex;

  for i := FirstItem to LastItem do
  begin
    CanvasStack.Push(Canvas);
    PaintItem(i);
    CanvasStack.Pop;
  end;
  inherited;
end;

procedure TzScrollObjInspectorList.PaintBkgnd(Canvas: TCanvas);
var
  LColor: TColor;
begin
  Canvas.Refresh;
  LColor := Color;
  if UseStyleColor then
    LColor := StyleServices.GetStyleColor(scWindow);
  Canvas.Brush.Color := LColor;
  Canvas.FillRect(ClientRect);
end;

procedure TzScrollObjInspectorList.PaintItem(Index: Integer);
begin
  { ==> Override <== }
end;

procedure TzScrollObjInspectorList.UpdateScrollBar;
begin
  FSI.cbSize := SizeOf(FSI);
  FSI.fMask := SIF_RANGE or SIF_PAGE;
  FSI.nMin := 0;
  FSI.nMax := VisiblePropCount - 1;
  FSI.nPage := GetMaxItemCount;
  if Assigned(Parent) and not(csDestroying in ComponentState) then
  begin
    SetScrollInfo(Handle, SB_VERT, FSI, False);
    InvalidateNC;
  end;
end;

procedure TzScrollObjInspectorList.WMERASEBKGND(var Message: TWMEraseBkgnd);
begin
  { Background will be painted on the WM_PAINT event ! }
  Message.Result := 1;
end;

procedure TzScrollObjInspectorList.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateScrollBar;
end;

procedure TzScrollObjInspectorList.WMVScroll(var Message: TWMVScroll);
var
  YPos: Integer;
  P: TPoint;
  procedure DoScrollWindow(XAmount, YAmount: Integer);
  var
    LScrollArea: TRect;
    hrgnUpdate: HRGN;
    ScrollFlags: UINT;
    procedure VertScrollChilds(pExcludeRect: PRect);
    var
      i: Integer;
      L: Integer;
      Child: TControl;
    begin
      { Manually Scroll Childs when ScrollFlags <> SW_SCROLLCHILDREN ! }
      for i := 0 to Self.ControlCount - 1 do
      begin
        Child := Self.Controls[i];
        if not(Child is TzPropInspButton) and (Child.Visible) then
        begin
          L := Child.Top + YAmount;
          if Assigned(pExcludeRect) and pExcludeRect.Contains(Point(Child.Left, L)) then
          begin
            if YAmount < 0 then
              Dec(L, pExcludeRect.Height)
            else
              Inc(L, pExcludeRect.Height)
          end;
          Child.Top := L;
          Child.Update;
        end;
      end;
    end;

  begin
    { If the header is visible
      => We must exclude the header area from being scrolled ! }
    if FShowHeader then
    begin
      UpdateWindow(Handle);
      LScrollArea := Rect(0, HeaderRect.Height, ClientWidth, ClientHeight);
      ScrollFlags := SW_INVALIDATE or SW_SCROLLCHILDREN;
      { Set the area that will be updated by the ScrollWindowEx function ! }
      with LScrollArea do
        hrgnUpdate := CreateRectRgn(Left, Top, Right, Bottom);
      ScrollWindowEx(Handle, XAmount, YAmount, nil, @LScrollArea, hrgnUpdate, nil, ScrollFlags);
      DeleteObject(hrgnUpdate);
    end
    else
    begin
      ScrollWindow(Handle, XAmount, YAmount, nil, nil);
      { Update the non validated area . }
      UpdateWindow(Handle);
    end;
    {
      ScrollFlags := SW_INVALIDATE ;
      if Assigned(pHeaderRect) then
      VertScrollChilds(pHeaderRect); // Manually Scroll Childs .
    }

  end;

begin
  { if the header is visible and the Edit is visible,
    the Edit caret will be painted over the header.
    we need first to hide the caret before scrolling .
  }
  if FShowHeader and (WinInWin(GetCaretWin, Handle)) and IsCaretVisible then
    HideCaret(0);
  FSI.cbSize := SizeOf(FSI);
  FSI.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_VERT, FSI);
  YPos := FSI.nPos;
  case Message.ScrollCode of
    SB_TOP:
      FSI.nPos := FSI.nMin;
    SB_BOTTOM:
      FSI.nPos := FSI.nMax;
    SB_LINEUP:
      FSI.nPos := FSI.nPos - 1;
    SB_LINEDOWN:
      FSI.nPos := FSI.nPos + 1;
    SB_PAGEUP:
      FSI.nPos := FSI.nPos - FSI.nPage;
    SB_PAGEDOWN:
      FSI.nPos := FSI.nPos + FSI.nPage;
    SB_THUMBTRACK:
      FSI.nPos := FSI.nTrackPos;
    SB_THUMBPOSITION: { VCL Style Support ! }
      begin
        { We can ignore this param if the VCL Style is not enabled ! }
        { VCL Style use SB_THUMBPOSITION instead of SB_THUMBTRACK ! }
        {
          if the Vcl Style is enabled and the user is scrolling ,
          the ScrollInfo pos is already set => (YPos - FSI.nPos) is always = 0.
        }
        // DbgPrint('Pos' + ' = ' + IntToStr(Message.Pos));
        DoScrollWindow(0, FItemHeight * (FPrevScrollPos - FSI.nPos));
        FPrevScrollPos := Message.Pos;
        Exit; // must exit
      end;
    SB_ENDSCROLL:
      begin
        { Restore caret visibility ! }
        if FShowHeader and (WinInWin(GetCaretWin, Handle)) and not IsCaretVisible then
          if GetCaretControl <> nil then
          begin
            GetCaretPos(P);
            P := GetCaretControl.ClientToParent(P);
            if not HeaderRect.Contains(P) then
              ShowCaret(0);
          end;
      end;
  end;
  FSI.fMask := SIF_POS;
  SetScrollInfo(Handle, SB_VERT, FSI, True);
  GetScrollInfo(Handle, SB_VERT, FSI);
  { If the position has changed, scroll window and Update it. }
  if (FSI.nPos <> YPos) then
    DoScrollWindow(0, FItemHeight * (YPos - FSI.nPos));
  { Save the current pos ! }
  FPrevScrollPos := FSI.nPos;
end;

procedure TzScrollObjInspectorList.WMWINDOWPOSCHANGED(var Message: TWMWindowPosChanged);
begin
  inherited;
  UpdateScrollBar;
end;

{ TzCustomObjInspector }

function TzCustomObjInspector.CanDrawChevron(Index: Integer): Boolean;
var
  PItem: PPropItem;
  iOrd: Integer;
begin
  Result := False;
  if (Index > -1) and (Index = FSelectedIndex) then
  begin
    PItem := FVisibleItems.Items[Index];
    iOrd := GetItemOrder(PItem);
    if iOrd > 0 then
      Exit(True)
    else if (iOrd = 0) and not(PItem.HasChild) then
      Exit(True);
  end;
end;

constructor TzCustomObjInspector.Create(AOwner: TComponent);
begin
  inherited;
  if csDesigning in ComponentState then
    Component := Self;
  FAllowSearch := True;
  FShowItemHint := True;
  FIsItemHint := False;
  FBoldHint := False;
  FPropsNeedHint := False;
  FValuesNeedHint := False;
  FOnGetItemReadOnly := nil;
  FOnItemSetValue := nil;
  FOnExpandItem := nil;
  FOnCollapseItem := nil;
  FOnSelectItem := nil;
  FSelItem := TPropItem.Empty;
  ParentBackground := False;
  DoubleBuffered := True;
  FShowGutter := True;
  FGutterWidth := 12;
  FNameColor := clBtnText;
  FGutterColor := clCream;
  FGutterEdgeColor := clGray;
  FReadOnlyColor := clGrayText;
  FHighlightColor := RGB(224, 224, 224);
  FReferencesColor := clMaroon;
  FSubPropertiesColor := clGreen;
  FValueColor := clNavy;
  FCategoryColor := $00E0E0E0;
  FCategoryTextColor := $00400080;
  FNonDefaultValueColor := clNavy;
  FBoldNonDefaultValue := True;
  FShowGridLines := False;
  FGridColor := clBlack;
  FAutoCompleteText := True;
  FTrackChange := False;
  FSepTxtDis := 4;
  FSelectedIndex := -1;
  FPropInspEdit := TzPropInspEdit.Create(Self, Self);
  FPropInspEdit.Visible := False;
  if not(csDesigning In ComponentState) then
    FPropInspEdit.Parent := Self;
  FPropInspEdit.BorderStyle := bsNone;
end;

procedure TzCustomObjInspector.CreateWnd;
begin
  inherited;
  FSelectedIndex := -1;
  if not(csDesigning in ComponentState) then
    RegisterHotKey(Handle, 0, 0, VK_TAB);
end;

destructor TzCustomObjInspector.Destroy;
begin
  inherited;
end;

function TzCustomObjInspector.DoCollapseItem(PItem: PPropItem): Boolean;
var
  i: Integer;
  PChild: PPropItem;
begin
  Result := PItem.HasChild;
  if not Result then
    Exit;
  if Assigned(FOnCollapseItem) then
    if not FOnCollapseItem(Self, PItem) then
      Exit(False);
  Result := False; // Indicate that item is already Collapsed !

  for i := 0 to PItem.Count - 1 do
  begin
    PChild := PItem.Items[i];
    if Assigned(PChild) then
    begin
      if PChild.FVisible then
      begin
        if PChild.HasChild then
          DoCollapseItem(PChild);
        if FPropInspEdit.FPropItem = PChild then
          FPropInspEdit.Visible := False;
        Result := True;
      end;
      PChild.FVisible := False;
      if FSaveVisibleItems.Contains(PChild.QualifiedName) then
        FSaveVisibleItems.Remove(PChild.QualifiedName);
    end;
  end;
  // PItem.FVisible := False;
  // if FSaveVisibleItems.Contains(PItem.QualifiedName) then
  // FSaveVisibleItems.Remove(PItem.QualifiedName);
end;

function TzCustomObjInspector.DoExpandItem(PItem: PPropItem): Boolean;
var
  i: Integer;
  PChild: PPropItem;
  procedure MakeChildsVisible(PParent: PPropItem; Visible: Boolean);
  var
    J: Integer;
    P: PPropItem;
  begin
    for J := 0 to PParent.Count - 1 do
    begin
      P := PParent.Items[J];
      P.FVisible := Visible;
      if FExpandedList.Contains(P.QualifiedName) then
        MakeChildsVisible(P, True);
      if not FSaveVisibleItems.Contains(P.QualifiedName) then
        FSaveVisibleItems.Add(P.QualifiedName);
    end;
  end;

begin
  Result := PItem.HasChild;
  if not Result then
    Exit;
  if FCircularLinkProps.Contains(PItem.QualifiedName) then
    Exit(False);
  if Assigned(FOnExpandItem) then
    if not FOnExpandItem(Self, PItem) then
      Exit(False);

  Result := False; // Indicate that item is already Expanded !

  if not FExpandedList.Contains(PItem.QualifiedName) then
    FExpandedList.Add(PItem.QualifiedName);

  if not FSaveVisibleItems.Contains(PItem.QualifiedName) then
    FSaveVisibleItems.Add(PItem.QualifiedName);

  for i := 0 to PItem.Count - 1 do
  begin
    PChild := PItem.Items[i];
    if Assigned(PChild) then
    begin
      if not PChild.FVisible then
        Result := True;
      PChild.FVisible := True;
      if FExpandedList.Contains(PChild.QualifiedName) then
        MakeChildsVisible(PChild, True);
      if not FSaveVisibleItems.Contains(PChild.QualifiedName) then
        FSaveVisibleItems.Add(PChild.QualifiedName);
    end;
  end;
end;

procedure TzCustomObjInspector.DoExtraRectClick;
var
  PItem: PPropItem;
  Value: TValue;
begin
  if FReadOnly then
    Exit;
  PItem := FVisibleItems[FExtraRectIndex];
  if Assigned(FOnGetItemReadOnly) then
    if FOnGetItemReadOnly(Self, PItem) then
      Exit;
  Value := DefaultValueManager.GetExtraRectResultValue(PItem);
  DoSetValue(PItem, Value);
end;

function TzCustomObjInspector.DoSelectCaret(Index: Integer): Boolean;
var
  X, Y, i, Offset: Integer;
  s: string;
begin
  Result := False;
  if (Index > -1) and (Index < FVisibleItems.Count - 1) then
    if CanFocus then
    begin
      SelectItem(Index);
      if GetFocus <> Handle then
        SetFocus;
      X := PropTextRect[Index].Left;
      Y := ItemRect[Index].Top;
      s := FSearchText;
      Offset := 0;
      if not s.IsEmpty then
      begin
        for i := 1 to Length(s) do
          { Calc caret pos }
          Offset := Offset + Canvas.TextWidth(s[i]);
      end;
      SetCaretPos(X + Offset - 1, Y + 1);
      ShowCaret(Handle);
      Result := True;
    end;
end;

function TzCustomObjInspector.DoSetValue(PropItem: PPropItem; var Value: TValue): Boolean;
begin
  Result := Assigned(PropItem);
  if not Result then
    Exit;
  if Assigned(FOnItemSetValue) then
    Result := FOnItemSetValue(Self, PropItem, Value);
  if Result then
    DefaultValueManager.SetValue(PropItem, Value);
  if Result then
  begin
    if PropItem.IsClass then
      { Must rebuild the list . }
      UpdateProperties();
    FPropInspEdit.UpdateEditText;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.ExpandAll;
var
  i: Integer;
begin
  FExpandedList.Clear;
  FSaveVisibleItems.Clear;
  UpdateItems;
  for i := 0 to FItems.Count - 1 do
    FItems.Items[i].FVisible := True;
  UpdateVisibleItems;
  UpdateScrollBar;
  UpdateEditControl(False);
  Invalidate;
end;

function TzCustomObjInspector.ExpandItem(PItem: PPropItem): Boolean;
begin
  Result := DoExpandItem(PItem);
  if Result then
    UpdateProperties(True);

end;

procedure TzCustomObjInspector.CollapseAll;
begin
  FSaveVisibleItems.Clear;
  FExpandedList.Clear;
  UpdateProperties(True);
end;

function TzCustomObjInspector.CollapseItem(PItem: PPropItem): Boolean;
begin
  Result := DoCollapseItem(PItem);
  if Result then
    UpdateProperties(True);
end;

function TzCustomObjInspector.GetExtraRect(Index: Integer): TRect;
var
  w: Integer;
  PItem: PPropItem;
  R: TRect;
begin
  Result := TRect.Empty;
  PItem := FVisibleItems[Index];
  w := DefaultValueManager.GetExtraRectWidth(PItem);
  if w > 0 then
  begin
    R := ValueRect[Index];
    Result := Rect(0, 0, w, w);
    Result := RectVCenter(Result, R);
    Result.Width := w;
    Result.Height := w;
    OffsetRect(Result, FSepTxtDis, 0);
  end;
end;

function TzCustomObjInspector.GetItemRect(Index: Integer): TRect;
var
  vIndex, Y: Integer;
begin
  Result := TRect.Empty;
  if Index > -1 then
  begin
    vIndex := IndexToVirtualIndex(Index);
    Y := GetItemTop(vIndex);
    Result := Rect(0, Y, Width, Y + FItemHeight);
  end;
end;

function TzCustomObjInspector.GetPlusMinBtnRect(Index: Integer): TRect;
var
  X, Y: Integer;
  pOrdPos, POrd: Integer;
  R: TRect;
  cY: Integer;
begin
  Result := TRect.Empty;
  POrd := GetItemOrder(FVisibleItems.Items[Index]);
  pOrdPos := (POrd * FGutterWidth) + FGutterWidth;
  X := (pOrdPos - PlusMinWidth) - 3;
  Y := GetItemTop(IndexToVirtualIndex(Index));
  R := Rect(0, Y, pOrdPos, Y + FItemHeight);
  cY := CenterPoint(R).Y - (PlusMinWidth div 2);
  Result := Rect(X, cY, X + PlusMinWidth, cY + PlusMinWidth);
end;

function TzCustomObjInspector.GetPropTextRect(Index: Integer): TRect;
begin
  Result := ItemRect[Index];
  Result.Left := (GetItemOrder(FVisibleItems[Index]) * FGutterWidth) + FGutterWidth + FSepTxtDis;
  Result.Right := FSplitterPos;
end;

function TzCustomObjInspector.GetSelectedItem: PPropItem;
var
  L: Integer;
begin
  Result := nil;
  L := -1;
  if (FSelectedIndex > -1) and (not FSelItem.IsEmpty) then
    L := FItems.IndexOfQName(FSelItem.QualifiedName);
  if L > -1 then
    Result := FItems.Items[L];
end;

function TzCustomObjInspector.GetValueRect(Index: Integer): TRect;
var
  vIndex, Y: Integer;
begin
  Result := TRect.Empty;
  if Index > -1 then
  begin
    vIndex := IndexToVirtualIndex(Index);
    Y := GetItemTop(vIndex);
    Result := Rect(FSplitterPos, Y, ClientWidth, Y + FItemHeight);
  end;
end;

function TzCustomObjInspector.GetValueTextRect(Index: Integer): TRect;
var
  w: Integer;
begin
  w := ExtraRect[Index].Width;
  Result := ValueRect[Index];
  Inc(Result.Left, FSepTxtDis);
  Inc(Result.Left, w);
  if w > 0 then
    Inc(Result.Left, FSepTxtDis);
end;

procedure TzCustomObjInspector.KeyDown(var Key: Word; Shift: TShiftState);
var
  LSelectedItem: PPropItem;
  LTxt: string;
  i: Integer;
  PItem: PPropItem;
begin
  inherited;
  if not FAllowSearch then
    Exit;
  LSelectedItem := SelectedItem;
  if (GetCaretWin = Handle) and (FSelectedIndex > -1) and Assigned(LSelectedItem) then
  begin
    LTxt := VKeyToStr(Key);
    if LTxt.IsEmpty then
    begin
      FSearchText := '';
      Exit;
    end;
    FSearchText := FSearchText + LTxt;
    for i := 0 to FVisibleItems.Count - 1 do
    begin
      PItem := FVisibleItems[i];
      if PItem.Parent = LSelectedItem.Parent then
        if IsStrFirst(FSearchText, PItem.Name) then
        begin
          { Respect the case sensitive }
          FSearchText := Copy(PItem.Name, 0, Length(FSearchText));
          if DoSelectCaret(i) then
            Exit;
        end;
    end;
  end;
  FSearchText := '';
end;

procedure TzCustomObjInspector.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  P: TPoint;
  PItem: PPropItem;
  MustUpdate: Boolean;
  SaveItem: TPropItem;
begin
  inherited;
  if CanFocus then
    WinApi.Windows.SetFocus(Handle);
  FSearchText := '';
  FExtraRectIndex := -1;
  P := Point(X, Y);
  if SplitterRect.Contains(P) then
    Exit;
  if FShowHeader and HeaderRect.Contains(P) then
    Exit;
  if FTrackChange then
    if NeedUpdate then // In case that some property was changed outside of the Inspector !
      UpdateProperties();
  MustUpdate := False; // No need to Update .
  Index := GetIndexFromPoint(P);
  if Index > -1 then
  begin
    PItem := FVisibleItems.Items[Index];
    if not FTrackChange then
      if ItemNeedUpdate(PItem) then
      begin
        SaveItem := PItem^;
        UpdateProperties;
        Index := FItems.IndexOfQName(SaveItem.QualifiedName);
        if Index < 0 then
        begin
          Invalidate;
          Exit;
        end;
        PItem := FItems.Items[Index];
        Index := FVisibleItems.IndexOf(PItem);
        PItem := FVisibleItems.Items[Index];
      end;
    if PlusMinBtnRect[Index].Contains(P) and (not IsItemCircularLink(PItem)) and PItem.HasChild then
    begin
      if PItem.Count = 0 then
      begin
        { FItems list does not contains childs ! }
        { => Must ReBuild the list ! }
        SaveItem := PItem^;
        UpdateItems;
        UpdateVisibleItems;
        Index := FItems.IndexOfQName(SaveItem.QualifiedName);
        if Index < 0 then
          Exit;
        PItem := FItems.Items[Index];
        Index := FVisibleItems.IndexOf(PItem);
        if Index < 0 then
          Exit;
      end;
      if PItem.Expanded then
      begin
        if FExpandedList.Contains(PItem.QualifiedName) then
          FExpandedList.Remove(PItem.QualifiedName);
        MustUpdate := DoCollapseItem(PItem);
      end
      else
        MustUpdate := DoExpandItem(PItem);
    end;
    if MustUpdate then
    begin
      // UpdateProperties(False);
      UpdateVisibleItems;
      UpdateScrollBar;
      if Index = FSelectedIndex then // SelectItem will not Invalidate !
        Invalidate;
    end;
    FClickTime := GetTickCount;
    SelectItem(Index);
    if PItem.IsCategory then
      Exit;
  end;

  if Index > -1 then
  begin
    if not ExtraRect[Index].IsEmpty then
      if ExtraRect[Index].Contains(P) then
        FExtraRectIndex := Index;
  end;

end;

procedure TzCustomObjInspector.CMHintShow(var Message: TCMHintShow);
begin
  if FIsItemHint and FShowItemHint then
  begin
    Message.HintInfo.HintPos := FHintPoint;
    Message.HintInfo.HintWindowClass := TItemHintWindow;
    Message.HintInfo.HintData := Pointer(FBoldHint);
  end
  else
    inherited;
  FIsItemHint := False;
end;

procedure TzCustomObjInspector.CMSTYLECHANGED(var Message: TMessage);
begin
  inherited;
  FSelectedIndex := -1;
  UpdateScrollBar;
  UpdateEditControl(False);
end;

procedure TzCustomObjInspector.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  w: Integer;
  P: TPoint;
  R: TRect;
  PItem: PPropItem;
  MustShow: Boolean;
begin
  inherited;
  if not FShowItemHint then
    Exit;
  P := Point(X, Y);
  Index := GetIndexFromPoint(P);
  MustShow := False;
  if (Index > -1) and (FPrevHintIndex <> Index) then
    if (FPropsNeedHint or FValuesNeedHint) then
    begin
      { Avoid this loop when there is no reason !
        ==> (FPropsNeedHint or FValuesNeedHint) must be True
        in order to show hint .
        ==> Check PaintItem routines !
      }
      ShowHint := False;
      FPrevHintIndex := Index;
      PItem := FVisibleItems[Index];
      if PItem.IsCategory then
        Exit;
      R := ValueRect[Index];
      FIsItemHint := True;
      if R.Contains(P) then
      begin
        FBoldHint := False;
        R := ValueTextRect[Index];
        Hint := PItem.ValueName;
        w := Canvas.TextWidth(Hint);
        MustShow := R.Width <= w;
      end
      else
      begin
        R := PropTextRect[Index];
        Hint := PItem.Name;
        FBoldHint := IsValueNoDefault(PItem.QualifiedName, PItem.ValueName);
        w := Canvas.TextWidth(Hint);
        MustShow := R.Width <= w;
      end;
      ShowHint := MustShow;
      if ShowHint then
      begin
        P.X := R.Left;
        P.Y := R.Top;
        P := ClientToScreen(P);
        FHintPoint := P;
      end;
    end;
end;

procedure TzCustomObjInspector.Paint;
var
  i: Integer;
  PItem: PPropItem;
begin
  inherited;
  for i := GetFirstItemIndex to GetLastItemIndex do
  begin
    PItem := FVisibleItems[i];
    if PItem.IsCategory then
      PaintCategory(i);
  end;
  CanvasStack.TrimExcess;
end;

procedure TzCustomObjInspector.PaintCategory(Index: Integer);
var
  PItem: PPropItem;
  R: TRect;
  LDetails: TThemedElementDetails;
  LColor, LTxtColor: TColor;
begin

  CanvasStack.Push(Canvas);
  LDetails := StyleServices.GetElementDetails(tcbCategoryNormal);
  PItem := FVisibleItems[Index];
  R := ItemRect[Index];
  Inc(R.Left, FGutterWidth + 1);
  LColor := FCategoryColor;
  if UseStyleColor then
    LColor := StyleServices.GetStyleColor(scCategoryButtons);
  Canvas.Brush.Color := LColor;
  Canvas.FillRect(R);
  LTxtColor := FCategoryTextColor;
  if UseStyleColor then
  begin
    if StyleServices.GetElementColor(LDetails, ecTextColor, LColor) then
      if LColor <> clNone then
        LTxtColor := LColor;
  end;
  Canvas.Font.Color := LTxtColor;

  Canvas.Font.Style := Canvas.Font.Style + [fsBold];
  Inc(R.Left, FSepTxtDis);
  DrawText(Canvas.Handle, PItem.Name, -1, R, DT_LEFT or DT_SINGLELINE or DT_VCENTER);

  Canvas.Font.Style := Canvas.Font.Style - [fsBold];
  CanvasStack.Pop;
end;

procedure TzCustomObjInspector.PaintItem(Index: Integer);
var
  X, Y, cY: Integer;
  R, pmR: TRect;
  vIndex, POrd: Integer;
  PItem: PPropItem;
  pOrdPos: Integer;
  DYT, DYB, PrevPos, NextPos: Integer;
  PropName: String;
  PPrevItem, PNextItem: PPropItem;
  xMax, xMin: Integer;
  HasPlusMinus: Boolean;
  LSaveColor: TColor;
  LColor: TColor;
begin

  if Index = GetFirstItemIndex then
  begin
    FPropsNeedHint := False;
    FValuesNeedHint := False;
  end;
  PItem := FVisibleItems.Items[Index];

  vIndex := IndexToVirtualIndex(Index);
  HasPlusMinus := False;
  Y := GetItemTop(vIndex);
  POrd := GetItemOrder(PItem);
  pOrdPos := (POrd * FGutterWidth) + FGutterWidth;

  R := Rect(0, Y, pOrdPos, Y + FItemHeight);
  if Index = FVisibleItems.Count - 1 then
    R.Height := Height;

  { Background color => will be used to paint property text . }
  LSaveColor := Canvas.Brush.Color;

  LColor := FGutterColor;
  if UseStyleColor then
    LColor := StyleServices.GetSystemColor(clBtnHighlight);
  Canvas.Brush.Color := LColor;
  Canvas.FillRect(R);

  pmR := PlusMinBtnRect[Index];
  if PItem.HasChild and not FCircularLinkProps.Contains(PItem.FQName) then
  begin
    DrawPlusMinus(Canvas, pmR.Left, pmR.Top, not PItem.Expanded);
    HasPlusMinus := True;
  end;
  if PItem.IsCategory then
  begin
    // Canvas.Refresh;
    // PaintCategory(Index);
  end
  else
  begin
    // Canvas.Refresh;

    if CanDrawChevron(Index) then
    begin
      cY := CenterPoint(pmR).Y - 3;
      X := pOrdPos - (3 * 2) - 1; // pOrdPos - (>>)-1
      // cY:=R.Top;
      if HasPlusMinus then
        Dec(X, PlusMinWidth + 2);
      DrawChevron(Canvas, sdRight, Point(X, cY), 3);
    end;

    PropName := PItem.Name;

    X := pOrdPos + 4;
    if FShowGridLines then
    begin
      Canvas.Pen.Color := FGridColor;
      DrawHorzDotLine(Canvas, pOrdPos + 1, Y, FSplitterPos);
    end;

    if FSelectedIndex = Index then
    begin
      R := Rect(pOrdPos + 1, Y + 1, FSplitterPos, Y + FItemHeight);
      LColor := FHighlightColor;
      if UseStyleColor then
        LColor := StyleServices.GetSystemColor(clHighlight);
      Canvas.Brush.Color := LColor;
      Canvas.FillRect(R);
    end
    else
      Canvas.Brush.Color := LSaveColor;

    R := Rect(X, Y, FSplitterPos, Y + FItemHeight);
    LColor := FNameColor;
    // Canvas.Font.Color := clFuchsia;
    if UseStyleColor then
      LColor := StyleServices.GetSystemColor(clBtnText);
    Canvas.Font.Color := LColor;

    if (PItem.Instance is TComponent) and (PItem.Instance <> PItem.Component) then
      Canvas.Font.Color := FSubPropertiesColor;

    if IsPropTypeDerivedFromClass(PItem.Prop.PropertyType, TComponent) then
      Canvas.Font.Color := FReferencesColor;

    if (not PItem.Prop.IsWritable) and (not PItem.IsClass) then
      Canvas.Font.Color := FReadOnlyColor;

    Canvas.Refresh;
    R := PropTextRect[Index];
    DrawText(Canvas.Handle, PropName, -1, R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

    if Canvas.TextWidth(PropName) > R.Width then
      FPropsNeedHint := True;

    Canvas.Brush.Color := LSaveColor;
    { ====> Paint Item Value <==== }
    PaintItemValue(PItem, Index);

    if Canvas.TextWidth(PItem.ValueName) > ValueTextRect[Index].Width then
      FValuesNeedHint := True;

    Canvas.Brush.Color := LSaveColor;
    Canvas.Pen.Color := FGridColor;

    if (FSelectedIndex = Index) then
    begin
      DrawHorzDotLine(Canvas, FSplitterPos, Y, Width);
      DrawHorzDotLine(Canvas, FSplitterPos, Y + FItemHeight, Width);
    end
    else if FShowGridLines then
    begin
      DrawHorzDotLine(Canvas, FSplitterPos, Y, Width);
    end;
  end;
  { ==> Draw gutter line <== }

  if not FShowGutter then
    Exit;
  // Canvas.Pen.Color := clFuchsia;
  LColor := FGutterEdgeColor;
  if UseStyleColor then
    LColor := StyleServices.GetStyleColor(scSplitter);
  Canvas.Pen.Color := LColor;
  Canvas.Refresh;
  DYT := 0;
  DYB := 0;
  PrevPos := 0;
  NextPos := 0;

  if (Index - 1) >= 0 then
  begin
    PPrevItem := FVisibleItems.Items[Index - 1];
    PrevPos := (GetItemOrder(PPrevItem) * FGutterWidth) + FGutterWidth;
    xMax := max(pOrdPos, PrevPos);
    xMin := min(pOrdPos, PrevPos);

    if PrevPos < pOrdPos then
    begin

      Canvas.MoveTo(xMin, Y - 2);
      Canvas.LineTo(xMin + 2, Y);
      Canvas.MoveTo(xMin + 2, Y);
      Canvas.LineTo(xMax - 2, Y);
      Canvas.MoveTo(xMax - 2, Y);
      Canvas.LineTo(xMax, Y + 2);
      DYT := 2;
    end
    else if PrevPos > pOrdPos then
    begin
      Canvas.MoveTo(xMax, Y - 2);
      Canvas.LineTo(xMax - 2, Y);
      Canvas.MoveTo(xMax - 2, Y);
      Canvas.LineTo(xMin + 2, Y);
      Canvas.MoveTo(xMin + 2, Y);
      Canvas.LineTo(xMin, Y + 2);
      DYT := 2;
    end;
  end;

  Canvas.MoveTo(pOrdPos, Y + DYT);
  if (Index + 1) < FVisibleItems.Count then
  begin
    PNextItem := FVisibleItems.Items[Index + 1];
    NextPos := (GetItemOrder(PNextItem) * FGutterWidth) + FGutterWidth;
    if pOrdPos <> NextPos then
      DYB := 2;
  end;
  Canvas.LineTo(pOrdPos, Y + FItemHeight - DYB);

  if (Index = FVisibleItems.Count - 1) then
  begin
    Canvas.MoveTo(pOrdPos, Y + FItemHeight - DYB);
    Canvas.LineTo(pOrdPos, Height);
  end;

end;

procedure TzCustomObjInspector.PaintItemValue(PItem: PPropItem; Index: Integer);
var
  R: TRect;
begin
  CanvasStack.Push(Canvas);
  R := ValueRect[Index];
  DefaultValueManager.PaintValue(Canvas, Index, PItem, R);
  CanvasStack.Pop;
end;

procedure TzCustomObjInspector.SelectItem(Index: Integer);
var
  LSI: TScrollInfo;
  procedure DoSetScrollInfo;
  begin
    SetScrollInfo(Handle, SB_VERT, LSI, True);
    if UseStyleBorder then
      InvalidateNC;
  end;

begin
  if (Index < 0) then
  begin
    FSelectedIndex := -1;
    FSelItem := TPropItem.Empty;
    Invalidate;
    Exit;
  end;
  if (Index < FVisibleItems.Count) then
  begin
    if (Index <> FSelectedIndex) then
    begin
      if Assigned(FOnSelectItem) then
        if not FOnSelectItem(Self, FVisibleItems.Items[Index]) then
          Exit;
      LSI.cbSize := SizeOf(FSI);
      LSI.fMask := SIF_POS;
      FSelectedIndex := Index;
      if (FSelectedIndex < GetFirstItemIndex) then
      begin
        { Index out of page => Need to scroll ! }
        LSI.nPos := FSelectedIndex;
        DoSetScrollInfo;
      end
      else if (FSelectedIndex > GetLastItemIndex - 1) then
      begin
        { Index out of page => Need to scroll ! }
        LSI.nPos := 1 + FSelectedIndex - GetMaxItemCount;
        DoSetScrollInfo;
      end;
      FSelItem := FVisibleItems[Index]^;
      Invalidate;
      UpdateEditControl;
      Exit;
    end;
    Exit;
  end;
  raise OutOfRangeError.CreateRes(@SSelNonVisibleItemErr);
end;

procedure TzCustomObjInspector.SetAllowSearch(const Value: Boolean);
begin
  if FAllowSearch <> Value then
  begin
    FAllowSearch := Value;
  end;
end;

procedure TzCustomObjInspector.SetBoldNonDefaultValue(const Value: Boolean);
begin
  if Value <> FBoldNonDefaultValue then
  begin
    FBoldNonDefaultValue := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetGridColor(const Value: TColor);
begin
  if FGridColor <> Value then
  begin
    FGridColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetGutterColor(const Value: TColor);
begin
  if Value <> FGutterColor then
  begin
    FGutterColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetGutterEdgeColor(const Value: TColor);
begin
  if Value <> FGutterEdgeColor then
  begin
    FGutterEdgeColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetGutterWidth(const Value: Integer);
begin
  if Value > 40 then
    raise InspException.Create('Gutter Width must be less than 40');
  if FGutterWidth <> Value then
  begin
    FGutterWidth := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetHighlightColor(const Value: TColor);
begin
  if Value <> FHighlightColor then
  begin
    FHighlightColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetNameColor(const Value: TColor);
begin
  if Value <> FNameColor then
  begin
    FNameColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetNonDefaultValueColor(const Value: TColor);
begin
  if Value <> FNonDefaultValueColor then
  begin
    FNonDefaultValueColor := Value;
    Invalidate;
  end;
end;

function TzCustomObjInspector.SetPropValue(PropItem: PPropItem; var Value: TValue): Boolean;
begin
  Result := DoSetValue(PropItem, Value);
end;

procedure TzCustomObjInspector.SetReadOnlyColor(const Value: TColor);
begin
  if FReadOnlyColor <> Value then
  begin
    FReadOnlyColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetReferencesColor(const Value: TColor);
begin
  if Value <> FReferencesColor then
  begin
    FReferencesColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetShowGridLines(const Value: Boolean);
begin
  if Value <> FShowGridLines then
  begin
    FShowGridLines := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetShowGutter(const Value: Boolean);
begin
  if Value <> FShowGutter then
  begin
    FShowGutter := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetSubPropertiesColor(const Value: TColor);
begin
  if Value <> FSubPropertiesColor then
  begin
    FSubPropertiesColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SetValueColor(const Value: TColor);
begin
  if Value <> FValueColor then
  begin
    FValueColor := Value;
    Invalidate;
  end;
end;

procedure TzCustomObjInspector.SplitterPosChanged(var Pos: Integer);
begin
  if (Pos < FGutterWidth + 30) then
    Pos := FGutterWidth + 30;
  if (Pos > ClientWidth - 30) then
    Pos := ClientWidth - 30;
  inherited SplitterPosChanged(Pos);
  UpdateEditControl;
end;

procedure TzCustomObjInspector.UpdateEditControl;
var
  PItem: PPropItem;
  BtnWidth: Integer;
  LTxtValRect: TRect;
begin
  if Assigned(FPropInspEdit) then
    if Assigned(FPropInspEdit.Parent) then
      FPropInspEdit.Visible := False;
  if FSelectedIndex < 0 then
    Exit;
  UpdateSelIndex;
  PItem := SelectedItem;

  if Assigned(PItem) then
  begin
    if PItem.IsCategory then
    begin
      if FPropInspEdit.Visible then
        FPropInspEdit.Visible := False;
      Exit;
    end;
    LTxtValRect := ValueTextRect[FSelectedIndex];
    if SetValue and FPropInspEdit.Visible and (Assigned(FPropInspEdit.FPropItem)) then
      FPropInspEdit.DoSetValueFromEdit;

    FPropInspEdit.PropInfo := PItem;
    with ValueRect[FSelectedIndex] do
    begin
      if DefaultValueManager.HasButton(PItem) then
        BtnWidth := 17
      else
        BtnWidth := 0;
      FPropInspEdit.Left := LTxtValRect.Left;
      FPropInspEdit.Top := LTxtValRect.Top + 3;

      FPropInspEdit.Width := Width - BtnWidth;
      FPropInspEdit.Height := Height - 3;
    end;
    FPropInspEdit.Visible := True;
    FPropInspEdit.SetFocus;
    FPropInspEdit.UpdateEditText;
  end;
end;

procedure TzCustomObjInspector.UpdateProperties(const Repaint: Boolean);
begin
  UpdateItems;
  UpdateVisibleItems;
  UpdateScrollBar;
  UpdateSelIndex;
  UpdateEditControl(False);
  if Repaint then
    Invalidate;
end;

procedure TzCustomObjInspector.UpdateSelIndex;
var
  P: PPropItem;
begin
  P := SelectedItem;
  if Assigned(P) then
  begin
    FSelectedIndex := FVisibleItems.IndexOf(P);
    SelectItem(FSelectedIndex);
  end;
end;

procedure TzCustomObjInspector.WMHotKey(var Msg: TWMHotKey);
var
  LForm: TCustomForm;
begin
  inherited;
  LForm := GetFormRoot(Self);
  if Assigned(LForm) then
  begin
    if FAllowSearch and (Msg.HotKey = 0) then
      if Assigned(LForm.ActiveControl) then
        if (WinInWin(LForm.ActiveControl.Handle, Handle)) then
        begin
          { ActiveControl must be Self or childs of Self ! }
          if DoSelectCaret(FSelectedIndex) then
            Exit;
        end;
    { Translate the Tab to the parent to
      select controls that have TabStop !
    }
    LForm.Perform(CM_DialogKey, VK_TAB, 0);
  end;
end;

procedure TzCustomObjInspector.WMKILLFOCUS(var Msg: TWMKILLFOCUS);
begin

  if GetCaretWin = Handle then
    DestroyCaret;
end;

procedure TzCustomObjInspector.WMLBUTTONDBLCLK(var Message: TWMLBUTTONDBLCLK);
begin
  inherited;
end;

procedure TzCustomObjInspector.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
end;

procedure TzCustomObjInspector.WMLButtonUp(var Message: TWMLButtonUp);
var
  P: TPoint;
begin
  inherited;
  P := Point(Message.XPos, Message.YPos);
  if (FExtraRectIndex > -1) and not(ExtraRect[FExtraRectIndex].IsEmpty) then
    if ExtraRect[FExtraRectIndex].Contains(P) then
    begin
      DoExtraRectClick;
    end;
end;

procedure TzCustomObjInspector.WMSETFOCUS(var Msg: TWMSetFocus);
begin
  inherited;
  if FAllowSearch then
    CreateCaret(Handle, 0, 1, FItemHeight - 2);
end;

procedure TzCustomObjInspector.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_DESTROY:
      begin
        if not(csDesigning in ComponentState) then
          UnregisterHotKey(Handle, 0);
      end;
    WM_NCLBUTTONDOWN:
      begin
        { Make sure that Edit control recieve CM_CANCELMODE message . }
        SendCancelMode(Self);
      end;
  end;
end;

{ TzPropInspEdit }

procedure TzPropInspEdit.ButtonClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FList) then
  begin
    if IsWindowVisible(FList.Handle) then
      HideList
    else
      ShowList;
    Exit;
  end;
  ShowModalDialog;
end;

procedure TzPropInspEdit.CMCANCELMODE(var Message: TCMCancelMode);
begin
  inherited;
  if (Message.Sender = FButton) or (Message.Sender = FList) then
    Exit;
  if Assigned(FList) then
    if IsWindowVisible(FList.Handle) then
    begin
      HideList;
      DoSetValueFromList;
    end;
end;

procedure TzPropInspEdit.CMVISIBLECHANGED(var Message: TMessage);
begin
  inherited;
  if not Visible then
    FButton.Visible := False;
end;

constructor TzPropInspEdit.Create(AOwner: TComponent; Inspector: TzCustomObjInspector);
begin
  inherited Create(AOwner);
  ParentCtl3D := False;
  BorderStyle := TBorderStyle(0);
  Ctl3d := False;
  TabStop := False;

  FInspector := Inspector;
  FPropItem := nil;
  FList := nil;

  FButton := TzPropInspButton.Create(Self);
  FButton.OnMouseDown := ButtonClick;
end;

procedure TzPropInspEdit.DoSetValueFromList;
var
  ObjValue: TObject;
  Method: TMethod;
  NewValue: TValue;

begin
  NewValue := TValue.Empty;
  if FDefSelIndex = FList.ItemIndex then
    Exit;
  FDefSelIndex := FList.ItemIndex;
  if ReadOnly then
    Exit;
  if FList.ItemIndex < 0 then
    Exit;
  ObjValue := (FList.Items.Objects[FList.ItemIndex]);
  if FPropItem.Prop.PropertyType.TypeKind = tkMethod then
  begin
    Method.Code := ObjValue;
    Method.Data := FPropItem.ComponentRoot;
    NewValue := DefaultValueManager.GetValue(FPropItem, Method);
  end
  else
    NewValue := DefaultValueManager.GetValue(FPropItem, ObjValue);
  FInspector.DoSetValue(FPropItem, NewValue);
end;

procedure TzPropInspEdit.DoDblClick;
var
  L: Integer;
begin
  inherited;
  if DefaultValueManager.HasDialog(FPropItem) then
    ShowModalDialog
  else if Assigned(FList) then
  begin
    if FList.Items.Count > 0 then
    begin
      L := FList.ItemIndex + 1;
      if L >= FList.Items.Count then
        L := 0;
      FList.Selected[L] := True;
      DoSetValueFromList;
    end;
  end;
end;

procedure TzPropInspEdit.DoSetValueFromEdit;
var
  s: string;
  vSInt: Int64;
  vUInt: UInt64;
  Value: TValue;
  Index: Integer;
begin

  if not FTxtChanged then
    Exit;
  FTxtChanged := False;
  if ReadOnly then
    Exit;
  if not FPropItem.Prop.IsWritable then
    Exit;
  if (FPropItem.IsSet) then
    Exit;

  s := Text;
  if Trim(FPropItem.ValueName) = Trim(s) then
    Exit;
  if s = '' then
  begin
    vUInt := 0;
    Value := DefaultValueManager.GetValue(FPropItem, vUInt);
    FInspector.DoSetValue(FPropItem, Value);
    Exit;
  end
  else if Assigned(FList) then
  begin
    Index := FList.Items.IndexOf(s);
    if Index > -1 then
    begin
      FList.Selected[Index] := True;
      DoSetValueFromList;
      Exit;
    end
    else
    begin
      if not DefaultValueManager.ValueHasOpenProbabilities(FPropItem) then
      begin
        raise InvalidPropValueError.CreateRes(@SInvalidPropValueErr);
        Exit;
      end;
    end
  end;
  Value := FPropItem.Value;
  if IsValueSigned(Value) then
  begin
    vSInt := DefaultValueManager.StrToValue<Int64>(FPropItem, s);
    Value := DefaultValueManager.GetValue(FPropItem, vSInt);
  end
  else
  begin
    vUInt := DefaultValueManager.StrToValue<UInt64>(FPropItem, s);
    Value := DefaultValueManager.GetValue(FPropItem, vUInt);
  end;
  FInspector.DoSetValue(FPropItem, Value);
  SelectAll;
end;

procedure TzPropInspEdit.HideList;
begin
  if Assigned(FList) and (FList.HandleAllocated) then
    ShowWindow(FList.Handle, SW_HIDE);
end;

procedure TzPropInspEdit.PropInfoChanged;
begin
  FTxtChanged := False;
  if FInspector.FReadOnly then
    ReadOnly := True
  else
  begin
    ReadOnly := not FPropItem.Prop.IsWritable;
    if FPropItem.IsSet then
      ReadOnly := True;
  end;
  if not ReadOnly then
    if Assigned(FInspector.FOnGetItemReadOnly) then
      ReadOnly := FInspector.FOnGetItemReadOnly(FInspector, FPropItem);

  if ReadOnly then
    Font.Color := FInspector.FReadOnlyColor
  else
    Font.Color := GetSysColor(clWindowText);

  InitList;
end;

procedure TzPropInspEdit.SetPropItem(const Value: PPropItem);
begin
  if not FPropItem.EqualTo(Value) then
  begin
    FPropItem := Value;
    PropInfoChanged;
  end;
end;

procedure TzPropInspEdit.ShowList;
var
  NewHeight: Integer;
  P: TPoint;
begin
  if not Assigned(FList) then
    Exit;
  if FList.Items.Count = 0 then
    Exit;
  NewHeight := FList.ItemHeight * (FList.Items.Count) + 4;
  P := Point(Left - DefaultValueManager.GetExtraRectWidth(PropInfo), Top + Height + 2);
  P := Parent.ClientToScreen(P);
  if (NewHeight + P.Y) >= Screen.Height then
    NewHeight := Screen.Height - P.Y - 50;
  FList.Height := NewHeight;
  FList.Width := ClientWidth;

  SetWindowPos(FList.Handle, HWND_TOP, P.X, P.Y, 0, 0, SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
end;

procedure TzPropInspEdit.ShowModalDialog;
var
  DialogClass: TComponentClass;
  Dialog: TComponent;
  mr: Integer;
  Value: TValue;
begin
  if ReadOnly then
    Exit;
  DialogClass := nil;
  with DefaultValueManager do
  begin
    if HasDialog(FPropItem) then
      DialogClass := GetDialog(FPropItem);
    if Assigned(DialogClass) then
    begin
      mr := 0;
      Dialog := DialogClass.Create(Self);
      if (not(Dialog is TCommonDialog)) and (not(Dialog is TzInspDialog)) then
        raise DialogDerivedError.CreateRes(@SDialogDerivedErr);
      if Dialog is TzInspDialog then
        TzInspDialog(Dialog).PropItem := FPropItem;
      DialogCode(FPropItem, Dialog, dcInit);
      DialogCode(FPropItem, Dialog, dcShow);
      if Dialog is TCommonDialog then
        mr := Integer(TCommonDialog(Dialog).Execute)
      else if Dialog is TzInspDialog then
        mr := TzInspDialog(Dialog).ShowModal;
      PostMessage(Handle, WM_LBUTTONUP, 0, 0);
      if mr = mrOk then
      begin
        DialogCode(FPropItem, Dialog, dcFinished);
        Value := DialogResultValue(FPropItem, Dialog);
        FInspector.DoSetValue(FPropItem, Value);
      end;
      DialogCode(FPropItem, Dialog, dcBeforeDestroying);
      FreeAndNil(Dialog);
    end;
  end;
end;

procedure TzPropInspEdit.UpdateButton;
begin
  FButton.Visible := False;
  if ReadOnly then
    Exit;
  if not DefaultValueManager.HasButton(PropInfo) then
    Exit;
  if not FPropItem.Prop.IsWritable then
    Exit;
  FButton.Parent := Self.Parent;
  FButton.Left := Self.Parent.ClientWidth - 17;
  FButton.Top := Top - 3;
  FButton.Height := FInspector.FItemHeight; // 17;
  FButton.Width := 17;
  FButton.Visible := True;
end;

procedure TzPropInspEdit.UpdateEditText;
var
  LQName: String;
begin
  LQName := FPropItem.FQName;
  with FInspector do
  begin
    Self.Text := FPropItem.ValueName;
    if not FDefPropValue.ContainsKey(LQName) then
      FDefPropValue.Add(LQName, Self.Text);
    SelectAll;
  end;
end;

procedure TzPropInspEdit.InitList;
var
  ListClass: TPopupListClass;
  s: string;
  SelIndex: Integer;
begin
  if Assigned(FList) then
    FreeAndNil(FList);
  if ReadOnly then
    Exit;
  if not FPropItem.Prop.IsWritable then
    Exit;
  if not DefaultValueManager.HasList(FPropItem) then
  begin
    if (DefaultValueManager.HasDialog(FPropItem)) then
      FButton.DropDown := False;
    Exit;
  end;
  ListClass := DefaultValueManager.GetListClass(PropInfo);
  FList := ListClass.Create(Self);
  FList.FPropItem := FPropItem;
  FList.FPropEdit := Self;
  FList.Visible := False;
  FList.Parent := Self.Parent;
  FList.OnMouseDown := ListBoxMouseDown;
  if not(FList is TzCustomPopupListBox) then
    DefaultValueManager.GetListItems(FPropItem, FList.Items);
  { Select the default item value }
  s := FPropItem.ValueName;
  SelIndex := FList.Items.IndexOf(s);
  if SelIndex > -1 then
    FList.Selected[SelIndex] := True;
  FDefSelIndex := SelIndex;
  FButton.DropDown := True;
end;

procedure TzPropInspEdit.ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DoSetValueFromList;
end;

procedure TzPropInspEdit.WMWINDOWPOSCHANGED(var Message: TWMWindowPosChanged);
begin
  inherited;
  UpdateButton;
end;

procedure TzPropInspEdit.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_ACTIVATE:
      begin
        Message.WParam := WA_INACTIVE;
        Message.Result := 0;
        Exit;
      end;
  end;
  inherited WndProc(Message);
end;

procedure TzPropInspEdit.WMCHAR(var Message: TWMCHAR);
var
  FindText: string;
  i: Integer;
begin
  case Message.CharCode of
    vkReturn:
      begin
        FTxtChanged := True;
        DoSetValueFromEdit;
        Message.Result := 0; // No beep !
        Exit;
      end;
    vkClear:
      begin
        FTxtChanged := True;
        inherited;
        Exit;
      end;
    vkBack:
      begin
        inherited;
        Exit;
      end;
  end;
  inherited;
  FTxtChanged := True;

  if not FInspector.FAutoCompleteText then
    Exit;
  { Auto complete user input text }
  FindText := Text;
  if Assigned(FList) then
  begin
    for i := 0 to FList.Items.Count - 1 do
    begin
      if IsStrFirst(FindText, FList.Items[i]) then
      begin
        Text := FList.Items[i];
        SelStart := Length(FindText);
        SelLength := Length(FList.Items[i]) - 1;
        Exit;
      end;
    end;
  end;
end;

procedure TzPropInspEdit.WMKEYDOWN(var Message: TWMKEYDOWN);
var
  Index: Integer;
  ToList: Boolean;
begin
  ToList := Assigned(FList);
  if ToList then
    ToList := IsWindowVisible(FList.Handle);
  { ToList = True  ==> Keyboard message will translated to the ListBox .
    ToList = False ==> Keyboard message will be used to select item from the Inspector .
  }
  if ToList then
    Index := FList.ItemIndex
  else
    Index := FInspector.FSelectedIndex;

  case Message.CharCode of
    vkReturn:
      begin
        if ToList then
        begin
          HideList;
          DoSetValueFromList;
          Exit;
        end;
      end;
    vkUp:
      begin
        Dec(Index);
        Index := max(0, Index);
      end;
    vkDown:
      begin
        Inc(Index);
        Index := min(FInspector.VisiblePropCount - 1, Index);
      end;
  else
    begin
      inherited;
      Exit;
    end;
  end;
  {
    Must inherite before calling SelectItem !
    ==> In order that SelectAll works properly .
  }
  inherited;
  if ToList then
    FList.Selected[Index] := True
  else
    FInspector.SelectItem(Index);

end;

procedure TzPropInspEdit.WMKILLFOCUS(var Message: TWMKILLFOCUS);
begin
  inherited;
  if Assigned(FList) then
    if IsWindowVisible(FList.Handle) then
      HideList;
  DoSetValueFromEdit;
end;

procedure TzPropInspEdit.WMLBUTTONDBLCLK(var Message: TWMLBUTTONDBLCLK);
begin
  DoDblClick;
end;

procedure TzPropInspEdit.WMLButtonDown(var Message: TWMLButtonDown);
var
  LClickTime, DCL, Sub: Integer;
begin
  { When the PropInspEdit is activated ,
    The Inspector will not fire the WMLBUTTONDBLCLK message .
    => we need to detect the double click manually !
  }
  if FInspector.FClickTime <> -1 then
  begin
    DCL := 200; // GetDoubleClickTime;
    LClickTime := GetTickCount;
    Sub := LClickTime - FInspector.FClickTime;
    if (Sub) < DCL then
    begin
      DoDblClick;
    end;
    FInspector.FClickTime := -1;
  end;
  inherited;

end;

procedure TzPropInspEdit.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
end;

{ TzCustomValueManager }

class procedure TzCustomValueManager.DialogCode(const PItem: PPropItem; Dialog: TComponent; Code: Integer);
begin

end;

class function TzCustomValueManager.DialogResultValue(const PItem: PPropItem; Dialog: TComponent): TValue;
begin
  Result := PItem.Value;
  case GetValueType(PItem) of
    vtColor:
      Result := GetValue(PItem, TColorDialog(Dialog).Color);
    vtFont:
      Result := GetValue(PItem, TFontDialog(Dialog).Font);
  end;
end;

class function TzCustomValueManager.GetDialog(const PItem: PPropItem): TComponentClass;
begin
  Result := nil;
  case GetValueType(PItem) of
    vtObj, vtIcon:
      begin
        if PItem.Value.AsObject is TStrings then
          Exit(TStringsDialog)
        else if PItem.Value.AsObject is TGraphic then
          Exit(TGraphicDialog);
      end;
    vtColor:
      Result := TColorDialog;
    vtFont:
      Result := TFontDialog;
  end;
end;

class function TzCustomValueManager.GetExtraRectResultValue(const PItem: PPropItem): TValue;
var
  Value: TValue;
  BoolVal: Boolean;
  s: TIntegerSet;
  vOrd: Integer;
begin
  Value := PItem.Value;
  if PItem.IsSetElement then
  begin
    Integer(s) := GetEnumOrdValue(Value);
    vOrd := PItem.SetElementValue;
    if (vOrd in s) then
      BoolVal := False
    else
      BoolVal := True;
    Result := GetValue(PItem, BoolVal);
    Exit;
  end;
  case GetValueType(PItem) of
    vtBool:
      begin
        BoolVal := not(GetValueAs<Boolean>(Value));
        Result := GetValue(PItem, BoolVal);
      end;
  end;
end;

class function TzCustomValueManager.GetExtraRectWidth(const PItem: PPropItem): Integer;
var
  LDetails: TThemedElementDetails;
  Size: TSize;
begin
  Result := 0;
  case GetValueType(PItem) of
    vtBool, vtSetElement:
      begin
        LDetails := StyleServices.GetElementDetails(tbCheckBoxUnCheckedNormal);
        StyleServices.GetElementSize(0, LDetails, esActual, Size);
        Result := Size.Width;
      end;
    vtColor:
      Result := ColorWidth + 1;
  end;
end;

class function TzCustomValueManager.GetListClass(const PItem: PPropItem): TPopupListClass;
var
  Value: TValue;
begin
  Value := PItem.Value;
  if Value.TypeInfo = TypeInfo(TColor) then
    Exit(TzPopupColorListBox)
  else if Value.TypeInfo = TypeInfo(TCursor) then
    Exit(TzPopupCursorListBox);

  Result := TzPopupListBox;
end;

class procedure TzCustomValueManager.GetListItems(const PItem: PPropItem; Items: TStrings);
var
  Value: TValue;
  i: Integer;
  Root: TCustomForm;
  procedure GetMethodsItems;
  var
    LCtx: TRttiContext;
    LType: TRttiType;
    LMethods: TArray<TRttiMethod>;
    LMethod: TRttiMethod;
  begin
    LCtx := TRttiContext.Create;
    LType := LCtx.GetType(Root.ClassInfo);
    LMethods := LType.GetDeclaredMethods;
    for LMethod in LMethods do
    begin
      if PropSameMethodType(PItem.Prop.PropertyType, LMethod) then
      begin
        Items.AddObject(LMethod.Name, TObject(LMethod.CodeAddress));
      end;
    end;
  end;

begin
  Value := PItem.Prop.GetValue(PItem.Instance);
  Root := PItem.ComponentRoot;
  if Value.TypeInfo = TypeInfo(TColor) then
    Exit;
  if Value.TypeInfo = TypeInfo(TCursor) then
    Exit;

  if PItem.Prop.PropertyType.TypeKind = tkClass then
  begin
    if Assigned(Root) then
      for i := 0 to Root.ComponentCount - 1 do
        if IsClassDerivedFromClass(Root.Components[i].ClassType, TRttiInstanceType(PItem.Prop.PropertyType).MetaclassType) then
          // if SameStr(Root.Components[i].ClassName, PItem.Prop.PropertyType.ToString) then
          Items.AddObject(Root.Components[i].Name, TObject(Root.Components[i]));
    Exit;
  end
  else if PItem.Prop.PropertyType.TypeKind = tkMethod then
  begin
    if Assigned(Root) then
      GetMethodsItems;
    Exit;
  end;

  if PItem.IsSetElement then
  begin
    Items.AddObject('False', TObject(0));
    Items.AddObject('True', TObject(1));
    Exit;
  end;

  if PItem.Prop.PropertyType.IsOrdinal then
  begin
    for i := Value.TypeData.MinValue to Value.TypeData.MaxValue do
      Items.AddObject(GetEnumName(Value.TypeInfo, i), TObject(i));
    Exit;
  end;
end;

class function TzCustomValueManager.GetValue(const PItem: PPropItem; const Value): TValue;
var
  Val: TValue;
  s: TIntegerSet;
begin
  Result := TValue.Empty;
  Val := PItem.Value;
  case GetValueType(PItem) of
    vtMethod:
      begin
        TValueData(Val).FAsMethod := TMethod(Value);
        Exit(Val);
      end;
    vtObj:
      begin
        TValueData(Val).FAsObject := TObject(Value);
        Exit(Val);
      end;
    vtString:
      begin
        Val := Val.From(String(Value));
        Exit(Val);
      end;
    vtChar:
      begin
        TValueData(Val).FAsUByte := Byte(Value);
        Exit(Val);
      end;
  end;

  if PItem.IsSetElement then
  begin
    Integer(s) := GetEnumOrdValue(Val);
    if Boolean(Value) then
      Include(s, PItem.SetElementValue)
    else
      Exclude(s, PItem.SetElementValue);
    TValueData(Val).FAsSLong := Integer(s);
  end
  else
  begin
    if IsValueSigned(Val) then
      TValueData(Val).FAsSInt64 := Int64(Value)
    else
      TValueData(Val).FAsUInt64 := UInt64(Value);
  end;
  Result := Val;
end;

class function TzCustomValueManager.GetValueAs<T>(const Value: TValue): T;
var
  sValue: Int64; // Signed Value !
  uValue: UInt64; // UnSigned Value !
  sR: T absolute sValue; // Signed Result !
  uR: T absolute uValue; // UnSigned Result !
  ValSign: Boolean;
begin

  { Just to avoid : E2506 Method of parameterized type declared in interface section must not use local symbol 'IsValueSigned'
    => We can not call IsValueSigned !
  }
  { To Avoid Range check error we must check ValSign }
  ValSign := (Value.TypeData.MinValue < 0) or (Value.TypeData.MinInt64Value < 0);

  { Always use 64 bit data !
    => Delphi automatically will cast the result !
  }
  if ValSign then
  begin
    sValue := (TValueData(Value).FAsSInt64);
    Result := sR;
  end
  else
  begin
    uValue := (TValueData(Value).FAsUInt64);
    Result := uR;
  end;
end;

class function TzCustomValueManager.GetValueName(const PItem: PPropItem): string;
var
  Value: TValue;
  LObj: TObject;
  function GetComponentDisplayName(Prop: TRttiProperty; Comp: TComponent; Root: TCustomForm): String;
  var
    LCtx: TRttiContext;
    LType: TRttiType;
    LFields: TArray<TRttiField>;
    LField: TRttiField;
  begin
    LCtx := TRttiContext.Create;
    LType := LCtx.GetType(Root.ClassInfo);
    LFields := LType.GetDeclaredFields;
    for LField in LFields do
      if LField.FieldType.TypeKind = tkClass then
      begin
        if SameText(Comp.Name, LField.Name) then
          Exit(Comp.Name); // Component is declared in the designer form .
      end;
    // Result := Comp.GetParentComponent.Name + '.' + Comp.Name;
  end;

begin
  Value := PItem.Value;

  if PItem.IsSetElement then
  begin
    Result := BooleanToStr(SetEnumToBoolean(GetEnumOrdValue(Value), PItem.SetElementValue));
    Exit;
  end
  else if (Value.TypeInfo = TypeInfo(TColor)) then
  begin
    Result := ColorToString(GetValueAs<TColor>(Value));
    Exit;
  end
  else if (Value.TypeInfo = TypeInfo(TCursor)) then
  begin
    Result := CursorToString(GetValueAs<TCursor>(Value));
    Exit;
  end
  else if Value.IsObject then
  begin
    Result := '';
    if not Value.IsEmpty then
    begin
      LObj := GetValueAs<TObject>(Value);
      Result := Format('(%s)', [LObj.ToString]);
      if (LObj is TComponent) then
        if TComponent(LObj).Name <> '' then
          Result := TComponent(LObj).Name;
    end;
    Exit;
  end;
  if PItem.Prop.PropertyType.TypeKind = tkMethod then
  begin
    Result := GetMethodName(Value, PItem.ComponentRoot);
    Exit;
  end;
  Result := Value.ToString;
end;

class function TzCustomValueManager.GetValueType(const PItem: PPropItem): Integer;
var
  Value: TValue;
begin

  Value := PItem.Value;
  case PItem.Prop.PropertyType.TypeKind of
    tkMethod:
      Exit(vtMethod);
    tkString, tkWString, tkUString:
      Exit(vtString);
    tkWChar, tkChar:
      Exit(vtChar);
  end;
  if Value.TypeInfo = TypeInfo(TColor) then
    Exit(vtColor)
  else if Value.TypeInfo = TypeInfo(TCursor) then
    Exit(vtCursor)
  else if Value.TypeInfo = TypeInfo(TFont) then
    Exit(vtFont)
  else if Value.TypeInfo = TypeInfo(TIcon) then
    Exit(vtIcon)
  else if Value.TypeInfo = TypeInfo(Boolean) then
    Exit(vtBool)
  else if Value.TypeInfo = TypeInfo(Bool) then
    Exit(vtBool);

  if PItem.IsEnum then
    Exit(vtEnum);

  if PItem.IsSetElement then
    Exit(vtSetElement)
  else if PItem.IsSet then
    Exit(vtSet);

  if PItem.IsClass then
    Exit(vtObj);

  Result := vtUnknown;
end;

class function TzCustomValueManager.HasButton(const PItem: PPropItem): Boolean;
begin
  Result := False;
  case GetValueType(PItem) of
    vtFont:
      Exit(True);
  end;
  if HasList(PItem) or HasDialog(PItem) then
    Result := True;

end;

class function TzCustomValueManager.HasDialog(const PItem: PPropItem): Boolean;
begin
  Result := False;
  case GetValueType(PItem) of
    vtObj:
      begin
        if PItem.Value.AsObject is TStrings then
          Exit(True)
        else if PItem.Value.AsObject is TGraphic then
          Exit(True);

      end;
    vtColor, vtFont, vtIcon:
      begin
        Exit(True);
      end;
  end;
end;

class function TzCustomValueManager.HasList(const PItem: PPropItem): Boolean;
begin
  Result := False;

  case GetValueType(PItem) of
    vtObj:
      begin
        Result := IsPropTypeDerivedFromClass(PItem.Prop.PropertyType, TComponent);
        Exit;
      end;
    vtMethod, vtBool, vtColor, vtCursor, vtSetElement, vtEnum:
      begin
        Exit(True);
      end;
  end;
end;

class procedure TzCustomValueManager.PaintValue(Canvas: TCanvas; Index: Integer; const PItem: PPropItem; R: TRect);
var
  Value: TValue;
  ExtRect: TRect;
  ValueName: String;
  C: TColor;
  DC: HDC;
  LStyle: TCustomStyleServices;
  LDetails: TThemedElementDetails;
  VT: Integer;
  BoolVal: Boolean;
  LInspector: TzCustomObjInspector;
  LQName: String;
  LColor: TColor;
begin

  LStyle := StyleServices;
  LInspector := TzCustomObjInspector(PItem.Insp);
  Value := PItem.Value;
  VT := GetValueType(PItem);
  DC := Canvas.Handle;
  BoolVal := False;

  LInspector.CanvasStack.Push(Canvas);

  if (VT = vtBool) or (VT = vtSetElement) then
  begin
    case VT of
      vtBool:
        BoolVal := GetValueAs<Boolean>(Value);
      vtSetElement:
        BoolVal := SetEnumToBoolean(GetEnumOrdValue(Value), PItem.SetElementValue);
    end;
    if BoolVal then
      LDetails := LStyle.GetElementDetails(tbCheckBoxCheckedNormal)
    else
      LDetails := LStyle.GetElementDetails(tbCheckBoxUnCheckedNormal);
    ExtRect := LInspector.ExtraRect[Index];
    LStyle.DrawElement(DC, LDetails, ExtRect);
  end
  else if VT = vtColor then
  begin
    C := GetValueAs<TColor>(Value);
    ExtRect := LInspector.ExtraRect[Index];
    zFillRect(DC, ExtRect, ColorToRGB(C), clBlack, 1, 1);
  end;

  LInspector.CanvasStack.Pop;

  LQName := PItem.FQName;
  ValueName := PItem.ValueName;

  LColor := LInspector.FValueColor;
  if LInspector.UseStyleColor then
    LColor := StyleServices.GetSystemColor(clBtnText);
  Canvas.Font.Color := LColor;

  Canvas.Font.Style := Canvas.Font.Style - [fsBold];
  if LInspector.IsValueNoDefault(LQName, ValueName) then
  begin
    if not LInspector.UseStyleColor then
      Canvas.Font.Color := LInspector.FNonDefaultValueColor;
    if LInspector.FBoldNonDefaultValue then
      Canvas.Font.Style := [fsBold];
  end;

  R := LInspector.ValueTextRect[Index];
  DrawText(Canvas.Handle, ValueName, -1, R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

end;

class procedure TzCustomValueManager.SetValue(const PItem: PPropItem; var Value: TValue);
begin
  PItem.Prop.SetValue(PItem.Instance, Value);
end;

class function TzCustomValueManager.StrToValue<T>(const PItem: PPropItem; const s: string): T;
var
  vSInt: Int64;
  vUInt: UInt64;
  Value: TValue;
  ValSign: Boolean;
  sR: T absolute vSInt;
  uR: T absolute vUInt;
  E: Integer;
begin

  vUInt := 0;
  vSInt := 0;
  Value := PItem.Value;
  ValSign := (Value.TypeData.MinValue < 0) or (Value.TypeData.MinInt64Value < 0);
  case GetValueType(PItem) of
    vtString:
      begin
        vUInt := UInt64(Pointer(s));
        Result := uR;
        Exit;
      end;
    vtChar:
      begin
        { IsOrdinal = True , but TryStrToInt64 will fail ! }
        if s <> '' then
          vUInt := Ord(s[1]);
        Result := uR;
        Exit;
      end;
  end;

  if PItem.Prop.PropertyType.IsOrdinal then
  begin
    TryStrToInt64(s, vSInt);
    // TryStrToUInt64(s, vUInt);
    Val(s, vUInt, E);
  end;

  if ValSign then
    Result := sR
  else
    Result := uR;
end;

class function TzCustomValueManager.ValueHasOpenProbabilities(const PItem: PPropItem): Boolean;
begin
  Result := False;
  case GetValueType(PItem) of
    vtColor, vtString, vtUnknown:
      Exit(True);
  end;
end;

{ TzPropInspButton }

constructor TzPropInspButton.Create(AOwner: TComponent);
begin
  inherited;
  FDropDown := True;
end;

procedure TzPropInspButton.Paint;
var
  LDetails: TThemedElementDetails;
  LStyle: TCustomStyleServices;
  P: TPoint;
  DC: HDC;
  R: TRect;
begin
  R := ClientRect;

  DC := Canvas.Handle;
  LStyle := StyleServices;

  if IsMouseDown and IsMouseInControl then
    LDetails := LStyle.GetElementDetails(tbPushButtonPressed)
  else
    LDetails := LStyle.GetElementDetails(tbPushButtonNormal);

  if LStyle.HasTransparentParts(LDetails) then
    LStyle.DrawParentBackground(Handle, DC, nil, False);

  LStyle.DrawElement(DC, LDetails, ClientRect);
  P := Point((Width div 2) - 2, (Height div 2) - 2);
  if FDropDown then
    DrawArrow(Canvas, sdDown, P, 3)
  else
    LStyle.DrawText(DC, LDetails, '...', R, [tfCenter, tfSingleLine]);
end;

procedure TzPropInspButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  Invalidate;
end;

procedure TzPropInspButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Invalidate;
end;

{ TzPopupListBox }

procedure TzPopupListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := Style or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TzPopupListBox.CreateWnd;
begin
  inherited CreateWnd;
  WinApi.Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
end;

procedure TzPopupListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FPropEdit.HideList;
end;

procedure TzPopupListBox.WndProc(var Message: TMessage);
begin
  inherited;
end;

{ TzRttiType }
function TzRttiType.GetUsedProperties: TArray<TRttiProperty>;
var
  LBasePropList { ,LDecPropList } : TArray<TRttiProperty>;
  Prop: TRttiProperty;
  L: Integer;
  function Contains(PropArray: TArray<TRttiProperty>; AProp: TRttiProperty): Boolean;
  var
    LProp: TRttiProperty;
  begin
    Result := False;
    for LProp in PropArray do
      if LProp.Name = AProp.Name then
        Exit(True);
  end;

begin
  Result := GetDeclaredProperties;
  LBasePropList := GetProperties;
  // LDecPropList := GetDeclaredProperties;

  for Prop in LBasePropList do
  begin
    if Assigned(Prop) and (not Contains( { LDecPropList } Result, Prop)) then
    begin
      L := Length(Result) + 1;
      SetLength(Result, L);
      Result[L - 1] := Prop;
    end;
  end;

end;

{ TzObjectInspectorStyleHook }

constructor TzObjectInspectorStyleHook.Create(AControl: TWinControl);
begin
  inherited;
end;

procedure TzObjectInspectorStyleHook.WMVScroll(var Msg: TMessage);
begin
  inherited;
end;

{ TzObjectInspector }

class constructor TzObjectInspector.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TzObjectInspector, TzObjectInspectorStyleHook);
end;

class destructor TzObjectInspector.Destroy;
begin
  TCustomStyleEngine.UnRegisterStyleHook(TzObjectInspector, TzObjectInspectorStyleHook);
end;

{ TItemHintWindow }

function TItemHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: TCustomData): TRect;
begin
  FPaintBold := Boolean(AData);
  if FPaintBold then
    { Must set bold before inheriting ! }
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
  Result := inherited CalcHintRect(MaxWidth, AHint, AData);
end;

procedure TItemHintWindow.Paint;
begin
  if FPaintBold then
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
  inherited;
  Canvas.Font.Style := Canvas.Font.Style - [fsBold];
end;

{ TzObjectHost }

procedure TzObjectHost.AddObject(Obj: TObject; Name: String);
var
  P: TPairObjectName;
begin
  P.Key := Obj;
  P.Value := Name;
  FList.Add(P);
end;

constructor TzObjectHost.Create;
begin
  FList := TList<TPairObjectName>.Create;
end;

destructor TzObjectHost.Destroy;
begin
  FList.Free;
  inherited;
end;

{ TzInspDialog }

procedure TzInspDialog.DoCreate;
begin
  inherited;
end;

procedure TzInspDialog.InitDialog;
begin

end;

procedure TzInspDialog.SetPropItem(const Value: PPropItem);
begin
  if FPropItem <> Value then
  begin
    FPropItem := Value;
    InitDialog;
  end;
end;

end.
