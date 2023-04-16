object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FrmMain'
  ClientHeight = 413
  ClientWidth = 658
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
    Width = 658
    Height = 413
    Align = alClient
    TabOrder = 0
    object PnlAct: TPanel
      Left = 1
      Top = 1
      Width = 656
      Height = 32
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 652
      object EdtStore: TLabeledEdit
        Left = 72
        Top = 0
        Width = 502
        Height = 23
        Align = alCustom
        Anchors = [akTop, akRight, akBottom]
        EditLabel.Width = 36
        EditLabel.Height = 23
        EditLabel.Caption = #25968#25454#24211
        LabelPosition = lpLeft
        TabOrder = 0
        Text = ''
        ExplicitLeft = 68
      end
      object btnOpen: TButton
        Left = 580
        Top = 1
        Width = 75
        Height = 30
        Align = alRight
        Caption = #25171#24320
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnOpenClick
        ExplicitLeft = 576
      end
    end
    object PnlBtns: TPanel
      Left = 581
      Top = 33
      Width = 76
      Height = 379
      Align = alRight
      TabOrder = 1
      ExplicitLeft = 577
      ExplicitHeight = 371
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
      Width = 580
      Height = 379
      Align = alClient
      TabOrder = 2
      DesignSize = (
        580
        379)
      object Tab: TTabControl
        Left = 1
        Top = 356
        Width = 578
        Height = 22
        Align = alBottom
        TabOrder = 0
        TabPosition = tpBottom
        OnChange = TabChange
        ExplicitTop = 348
        ExplicitWidth = 574
      end
      object Log: TMemo
        Left = 1
        Top = 1
        Width = 578
        Height = 355
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
        ExplicitWidth = 574
        ExplicitHeight = 347
      end
      object btnClear: TButton
        Left = 552
        Top = 354
        Width = 28
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #9679
        TabOrder = 2
        OnClick = btnClearClick
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
