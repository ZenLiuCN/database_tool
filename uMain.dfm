object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FrmMain'
  ClientHeight = 410
  ClientWidth = 641
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  OnCloseQuery = FormCloseQuery
  TextHeight = 15
  object PnlMain: TPanel
    Left = 0
    Top = 0
    Width = 641
    Height = 410
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 637
    ExplicitHeight = 402
    object PnlAct: TPanel
      Left = 1
      Top = 1
      Width = 639
      Height = 32
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 635
      object LblStat: TLabel
        Left = 8
        Top = 3
        Width = 18
        Height = 15
        Caption = '('#9675')'
      end
      object EdtStore: TLabeledEdit
        Left = 88
        Top = 0
        Width = 469
        Height = 23
        Align = alCustom
        Anchors = [akTop, akRight, akBottom]
        EditLabel.Width = 36
        EditLabel.Height = 23
        EditLabel.Caption = #25968#25454#24211
        LabelPosition = lpLeft
        TabOrder = 0
        Text = ''
        ExplicitLeft = 84
      end
      object btnOpen: TButton
        Left = 563
        Top = 1
        Width = 75
        Height = 30
        Align = alRight
        Caption = #25171#24320
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnOpenClick
        ExplicitLeft = 559
      end
    end
    object PnlBtns: TPanel
      Left = 564
      Top = 33
      Width = 76
      Height = 376
      Align = alRight
      TabOrder = 1
      ExplicitLeft = 560
      ExplicitHeight = 368
      object btnBackup: TButton
        Left = 1
        Top = 151
        Width = 74
        Height = 75
        Align = alTop
        Caption = #22791#20221
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object btnReload: TButton
        Left = 1
        Top = 301
        Width = 74
        Height = 75
        Align = alTop
        Caption = #21152#36733
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object btnRestore: TButton
        Left = 1
        Top = 226
        Width = 74
        Height = 75
        Align = alTop
        Caption = #36824#21407
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object btnStart: TButton
        Left = 1
        Top = 1
        Width = 74
        Height = 75
        Align = alTop
        Caption = #21551#21160
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object btnStop: TButton
        Left = 1
        Top = 76
        Width = 74
        Height = 75
        Align = alTop
        Caption = #20572#27490
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
    end
    object PnlClient: TPanel
      Left = 1
      Top = 33
      Width = 563
      Height = 376
      Align = alClient
      TabOrder = 2
      ExplicitWidth = 559
      ExplicitHeight = 368
      DesignSize = (
        563
        376)
      object Tab: TTabControl
        Left = 1
        Top = 353
        Width = 561
        Height = 22
        Align = alBottom
        TabOrder = 0
        TabPosition = tpBottom
        OnChange = TabChange
        ExplicitTop = 345
        ExplicitWidth = 557
      end
      object Log: TMemo
        Left = 1
        Top = 1
        Width = 561
        Height = 352
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
        ExplicitWidth = 557
        ExplicitHeight = 344
      end
      object btnClear: TButton
        Left = 535
        Top = 351
        Width = 28
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #9679
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = btnClearClick
        ExplicitLeft = 531
        ExplicitTop = 343
      end
    end
  end
  object DlgOpen: TOpenDialog
    Options = [ofHideReadOnly, ofEnableSizing, ofForceShowHidden]
    Title = 'Open'
    Left = 55
    Top = 116
  end
  object Tray: TTrayIcon
    Hint = #25968#25454#24211#31649#29702
    BalloonHint = #21452#20987#36824#21407#31383#21475
    OnDblClick = TrayDblClick
    Left = 12
    Top = 189
  end
  object AppEvents: TApplicationEvents
    OnMinimize = AppEventsMinimize
    Left = 49
    Top = 49
  end
  object Tmr: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TmrTimer
    Left = 9
    Top = 49
  end
  object DlgSave: TSaveDialog
    Left = 9
    Top = 113
  end
end
