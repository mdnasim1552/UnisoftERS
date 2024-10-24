<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_TherapeuticProcedures_OGDTherapeuticProcedures" CodeBehind="OGDTherapeuticProcedures.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <%--<telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />--%>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .sub-table td {
            border: none;
        }

            .sub-table td:first-child {
                width: 195px;
            }

        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }

        .rblType label {
            margin-right: 20px;
        }

        .polypRemovalTypeList label {
            margin-right: 14px !important;
        }

        .BandLigationTR_Option {
            float: left;
            width: 160px;
            margin-right: 10px;
        }

        .BandLigationTR_OptionSm {
            float: left;
            width: 100px;
            margin-right: 10px;
        }

        .rtsSelected, .rtsSelected span {
            color: red;
        }

        .therapeuticProceduresHeight{
            height: 88vh !important;
        }

        .therapeuticsTableHeight{
            height: calc(70vh - 30px) !important;
        }
        #RAD_SPLITTER_PANE_CONTENT_radPaneNoneCheckBox{
            width: 780px !important;
        }
        #RAD_SPLITTER_PANE_CONTENT_ButtonsRadPane{
            width: 780px !important;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            width: 780px !important;
        }
    </style>

</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var ogdTheraputicsChange = false;
            var validationMsg = '';
            $(document).ready(function () {
                toggleArgonBeamRequired();
                toggleBandLigationRequired();
                toggleEndoscopicRequired();
                toggleFNARequired();
                toggleFNBRequired();
                toggleInjectionTherapyRequired();
                toggleStentInsertionRequired();
                toggleBalloonDilationRequired(); /* add by mostafiz */
                toggleVaricealSclerotherapyRequired();
                toggleBandingRequired();
                toggleCoilRequired();
                toggleClipRequired();

                $('#<%=EnterPolypDetailsRadButton.ClientID%>').on('click', function () {
                    window.parent.selectSpecificNode('Lesions');
                });

                $('#<%=ArgonBeamDiathermyCheckBox.ClientID%>').on('click', function () {
                    toggleArgonBeamRequired();
                });

                $('#<%=BandLigationCheckBox.ClientID%>').on('click', function () {
                    toggleBandLigationRequired();
                });

                $('#<%=EmrCheckBox.ClientID%>').on('click', function () {
                    toggleEndoscopicRequired();
                });

                $('#<%=FineNeedleAspirationCheckBox.ClientID%>').on('click', function () {
                    toggleFNARequired();
                });

                $('#<%=FineNeedleBiopsyCheckBox.ClientID%>').on('click', function () {
                    toggleFNBRequired();
                });

                $('#<%=InjectionTherapyCheckBox.ClientID%>').on('click', function () {
                    toggleInjectionTherapyRequired();
                });

                $('#<%=MarkingCheckBox.ClientID%>').on('click', function () {
                    toggleMarkingRequired();
                });

                $('#<%=StentInsertionCheckBox.ClientID%>').on('click', function () {
                    toggleStentInsertionRequired();
                });

                /* add by mostafiz */

                $('#<%=BalloonDilationCheckBox.ClientID%>').on('click', function () {
                    toggleBalloonDilationRequired();
                });

               /* add by mostafiz */

                $('#<%=VaricealSclerotherapyCheckBox.ClientID%>').on('click', function () {
                    toggleVaricealSclerotherapyRequired();
                });

                $('#<%=BandingPilesCheckBox.ClientID%>').on('click', function () {
                    toggleBandingRequired();
                });

                $('#<%=chkCoil.ClientID%>').on('click', function () {
                    toggleCoilRequired();
                });

                $('#<%=chkCoil.ClientID%>').on('click', function () {
                    toggleCoilRequired();
                });

                $('#form1').on('change', function () {
                    if (validateOGDTherapeutics())valueChanged();
                });

                $(window).on('beforeunload', function () {
                    if (ogdTheraputicsChange) {
                        if ($("#OesophagealDilatationCheckBox").is(':checked')) {
                            var vPerforation = $("#PerforationRadioButtonList").find(":checked").val();
                            if (vPerforation != 0 && vPerforation != 1) {
                                $("#OesophagealDilatationCheckBox").prop('checked', false);
                            }
                        }
                        $('#<%=SaveButton.ClientID%>').click();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

            function updatePolypsQty() {
                $find('<%= RadAjaxManager2.ClientID %>').ajaxRequest('update-polyps');
            }
            function savePage() {
                $find('<%= RadAjaxManager2.ClientID %>').ajaxRequest();
            }
            function valueChanged() {
                ogdTheraputicsChange = true;
                setTimeout(function () {
                    var valueToSave = false;
                    $("#TherapeuticsTable tr td:first-child").each(function () {
                        if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
                    });
                    if (!$('#chkNoneCheckBox').is(':checked') && !valueToSave && validateOGDTherapeutics())
                        localStorage.setItem('valueChanged', 'false');
                    else
                        localStorage.setItem('valueChanged', 'true');

                }, 10);
            }
            function validateOGDTherapeutics() {
                var oesophagealChecked = $("#OesophagealDilatationCheckBox").is(':checked');
                var otherChecked = false;
                $("#TherapeuticsTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox").attr('id') === 'OesophagealDilatationCheckBox' && $(this).find("input:checkbox").is(':checked')) {
                        var vPerforation = $("#PerforationRadioButtonList").find(":checked").val();
                        if (vPerforation != 0 && vPerforation != 1) {
                            validationMsg = 'Please select a value to state if there was perforation.';
                            setOGDTherapeuticsLocalStorage('true', validationMsg);
                        } else {
                            validationMsg = '';
                            setOGDTherapeuticsLocalStorage('false', validationMsg);
                        }
                    } else if ($(this).find("input:checkbox").attr('id') === 'OesophagealDilatationCheckBox' && !$(this).find("input:checkbox").is(':checked')) {
                        validationMsg = '';
                        setOGDTherapeuticsLocalStorage('false', validationMsg);
                    }
                    else if ($(this).find("input:checkbox").attr('id') !== 'OesophagealDilatationCheckBox' && $(this).find("input:checkbox").is(':checked')) {
                        otherChecked = true;
                    }
                });
                if (oesophagealChecked && !otherChecked) {
                    return validationMsg === '';
                } else if (!oesophagealChecked && otherChecked) {
                    return true;
                } else if (oesophagealChecked && otherChecked) {
                    return validationMsg === '';
                } else {
                    return true;
                }
            }
            function setOGDTherapeuticsLocalStorage(isValid, validationMsg) {
                localStorage.setItem('validationRequired', isValid);
                localStorage.setItem('validationRequiredMessage', validationMsg);
            }
        </script>
    </telerik:RadScriptBlock>
    <form id="form1" runat="server" style="overflow: hidden;">
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        </telerik:RadAjaxManager>
        <telerik:RadFormDecorator ID="rfdNoneCheckBox" runat="server" DecoratedControls="All" DecorationZoneID="divNoneCheckBox" Skin="Web20" />
        <telerik:RadFormDecorator ID="rfdOtherText" runat="server" DecoratedControls="All" DecorationZoneID="ButtonsRadPane" Skin="Web20" />
        <telerik:RadScriptManager ID="OGDTherapeuticRadScriptManager" runat="server" />
        
       
        <telerik:RadAjaxManager ID="RadAjaxManager2" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager2">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PolypectomyQtyRadNumericTextBox" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>

        <telerik:RadFormDecorator ID="RadFormDecorator4" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator3" runat="server" DecoratedControls="All" DecorationZoneID="RadWindow1" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="RadWindow2" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="SigmoidopexyWardInstructionRadWindow" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <div class="abnorHeader">Therapeutic Procedures</div>
        <div id="TabStripContainer" class="siteDetailsContentDiv">
            <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="680px" CssClass="therapeuticProceduresHeight" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                <telerik:RadPane ID="radPaneNoneCheckBox" runat="server" Height="40px" Scrolling="None" Index="0">
                    <div id="divNoneCheckBox" class="shaded-tab-header" style="padding-left: 10px;">
                        <asp:CheckBox ID="chkNoneCheckBox" runat="server" Text="None" ForeColor="Black" TabIndex="0" />
                        <span style="float: right">
                            <asp:RadioButtonList runat="server" RepeatDirection="Horizontal" ID="ObservedAssistedOptions">
                                <asp:ListItem ID="optObserved" runat="server" Text="Observed" />
                                <asp:ListItem ID="optAssisted" runat="server" Text="Assisted" />
                                <asp:ListItem ID="optIndependent" runat="server" Text="Trainer Independent" />
                                <asp:ListItem ID="optTrainerCompleted" runat="server" Text="Trainer Completed" />
                                <asp:ListItem ID="optIndependentEndo2" runat="server" style="visibility: hidden" />
                            </asp:RadioButtonList>
                        </span>
                    </div>

                </telerik:RadPane>

                <telerik:RadPane ID="ControlsRadPane" runat="server" Width="680px" CssClass="therapeuticsTableHeight">
                    <!-- Start of therapeutic procedures -->
                    <asp:HiddenField ID="hiddenTherapeuticId" runat="server" />
                    <asp:HiddenField ID="hiddenSiteId" runat="server" />


                    <asp:Panel ID="panTherapeuticsFormView" runat="server">
                        <div id="ContentDiv" style="overflow: auto">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="TherapeuticsTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 745px;">
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead style="display: none">
                                        </thead>
                                        <tbody>
                                            <!-- A's -->
                                            <tr id="argonBeamRowHide" runat="server" visible="false">

                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="ArgonBeamDiathermyCheckBox" runat="server" Checked='<%# Bind("ArgonBeamDiathermy")%>' Text="Argon beam diathermy" TabIndex="8" CssClass="toggleCheckBox" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 50px; visibility: hidden;">
                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermyWattsNumericTextBox" runat="server" TabIndex="9" DbValue='<%# Bind("ArgonBeamDiathermyWatts")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateArgonBeamKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                W &nbsp;&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermyPulsesNumericTextBox" runat="server" TabIndex="10" DbValue='<%# Bind("ArgonBeamDiathermyPulses")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateArgonBeamKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                pulses &nbsp;&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermySecsNumericTextBox" runat="server" TabIndex="11" DbValue='<%# Bind("ArgonBeamDiathermySecs")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5" NumberFormat-AllowRounding="true"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" AllowRounding="false" />
                                                                    <ClientEvents OnValueChanged="UpdateArgonBeamKJ" />
                                                                </telerik:RadNumericTextBox>
                                                                sec &nbsp;&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="ArgonBeamDiathermyKJNumericTextBox" runat="server" TabIndex="12" DbValue='<%# Bind("ArgonBeamDiathermyKJ")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="55px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                                kJ
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- B's -->
                                            <tr id="bandLigationHide" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td style="width: 150px">
                                                                <asp:CheckBox ID="BandLigationCheckBox" runat="server" Checked='<%# Bind("BandLigation")%>' Text="Band ligation" TabIndex="14" />
                                                            </td>
                                                            <td>
                                                                <span>&nbsp;&nbsp;&nbsp;Performed</span>
                                                                <telerik:RadNumericTextBox ID="BandLigationPerformedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" AllowRounding="false" />
                                                                    <ClientEvents OnValueChanged="BandLigationValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>&nbsp;&nbsp;&nbsp;Successful</span>
                                                                <telerik:RadNumericTextBox ID="BandLigationSuccessfulRadNumericTextBox" runat="server" TabIndex="12"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" AllowRounding="false" />
                                                                    <ClientEvents OnValueChanged="BandLigationSuccessfulValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <%--<td>
                                                                <span>Retreived</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BandLigationRetreivedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="BandingPilesTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="BandingPilesCheckBox" runat="server" Checked='<%# Bind("BandingPiles")%>' Text="Banding of piles" TabIndex="35" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">&nbsp;&nbsp;&nbsp;No of bands
                                                                <telerik:RadNumericTextBox ID="BandingNumRadNumericTextBox" runat="server" TabIndex="36" DbValue='<%# Bind("BandingNum")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="BalloonDilationTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr headrow="1">
                                                             <td style="border: none;">
                                                                <asp:CheckBox ID="BalloonDilationCheckBox" runat="server" Checked='<%# Bind("BalloonDilation")%>' Text="Balloon dilation" TabIndex="14" />
                                                             </td>
                                                              <td style="border: none; visibility: hidden;">
                                                                       &nbsp;&nbsp;&nbsp;type
                                                        <telerik:RadComboBox ID="BalloonDilationTypeComboBox" runat="server" Skin="Windows7" Width="100" TabIndex="54" MarkFirstMatch="true" />

                                                          

                                                        &nbsp;&nbsp;&nbsp;dia.
                                                        <telerik:RadNumericTextBox ID="BalloonDilationDiaNumericTextBox" runat="server" TabIndex="56" DbValue='<%# Bind("BalloonDilationDiameter")%>'
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>

                                                            <telerik:RadComboBox ID="BalloonDilationDiaUnitsComboBox" runat="server" Skin="Windows7" Width="50px" TabIndex="57" MarkFirstMatch="true" />
                                                        </td>
                                                            <%-- <td>
                                                                <span>Performed</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BalloonDilationPerformedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Successful</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BalloonDilationSuccessfulRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Retreived</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BalloonDilationRetreivedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="BotoxInjectionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="BotoxInjectionCheckBox" runat="server" Checked='<%# Bind("BotoxInjection")%>' Text="Botox injection" TabIndex="15" />
                                                            </td>
                                                            <%--<td>
                                                                <span>Performed</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BotoxInjectionPerformedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Successful</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BotoxInjectionSuccessfulRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Retreived</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BotoxInjectionRetreivedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="BougieDilationTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BougieDilationCheckBox" runat="server" Text="Bougie dilation" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="BicapElectroTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="BicapElectroCheckBox" runat="server" Checked='<%# Bind("BicapElectro")%>' Text="Bicap electrocautery" TabIndex="18" CssClass="toggleCheckBox" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">&nbsp;
                                                               
                                                                <telerik:RadComboBox ID="BicapElectroTypeComboBox" runat="server" Skin="Windows7" Width="150" TabIndex="54" DropDownAutoWidth="Enabled" MarkFirstMatch="true" />
                                                            </td>
                                                            <%--<td>
                                                                <span>Performed</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BicapElectroPerformedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Successful</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BicapElectroSuccessfulRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Retreived</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="BicapElectroRetreivedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- C's -->
                                            <tr id="ColonicDecompressionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="ColonicDecompressionCheckBox" runat="server" Checked='<%# Bind("ColonicDecompression")%>' Text="Colonic decompression" TabIndex="80" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="CryotherapyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="chkCryotherapy" runat="server" Checked='<%# Bind("Cryotherapy")%>' Text="Cryotherapy" TabIndex="60" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="CoilTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="chkCoil" runat="server" Checked='<%# Bind("Coil")%>' Text="Coil" TabIndex="60" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">qty&nbsp;
                                                               <telerik:RadNumericTextBox ID="CoilQty" runat="server" TabIndex="53" DbValue='<%# Bind("CoilQty")%>'
                                                                   IncrementSettings-InterceptMouseWheel="false"
                                                                   IncrementSettings-Step="1"
                                                                   Width="35px"
                                                                   MinValue="0">
                                                                   <%--<ClientEvents OnBlur="setCoilDefault" />--%>
                                                                   <NumberFormat DecimalDigits="0" />
                                                               </telerik:RadNumericTextBox>
                                                                &nbsp;&nbsp;&nbsp;type
                                                            <telerik:RadComboBox ID="cboCoilType" runat="server" Skin="Windows7" Width="150" TabIndex="54" DropDownAutoWidth="Enabled" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="clipRowHide" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="ClipCheckBox" runat="server" Checked='<%# Bind("Clip")%>' Text="Clip" TabIndex="80" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">&nbsp;&nbsp;&nbsp;Performed
                                                                <telerik:RadNumericTextBox ID="ClipRadNumericTextBox" runat="server" TabIndex="81" DbValue='<%# Bind("ClipNum")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="ClipValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Successful
                                                                <telerik:RadNumericTextBox ID="ClipSuccessfulRadNumericTextBox" runat="server" TabIndex="81" DbValue='<%# Bind("ClipNumSuccess")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="ClipSuccessValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- D's -->
                                            <tr id="DiathermyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="chkDiathermy" runat="server" Checked='<%# Bind("Diathermy")%>' Text="Diathermy" TabIndex="60" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">Watt&nbsp;
                                                               <telerik:RadNumericTextBox ID="DiathermyWatt" runat="server" TabIndex="53" DbValue='<%# Bind("DiathermyWatt")%>'
                                                                   IncrementSettings-InterceptMouseWheel="false"
                                                                   IncrementSettings-Step="5"
                                                                   Width="35px"
                                                                   MinValue="0">
                                                                   <NumberFormat DecimalDigits="0" />
                                                               </telerik:RadNumericTextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="DiverticulotomyTR" runat="server" visible="false">
                                            <td style="padding: 0px 0px 0px 6px;">
                                                <table style="width: 100%;">
                                                    <tr headrow="1">
                                                        <td style="border: none; width: 150px;">
                                                            <asp:CheckBox ID="DiverticulotomyCheckBox" runat="server" Checked='<%# Bind("Diverticulotomy")%>' Text="Diverticulotomy" TabIndex="60" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                            <!-- E's -->
                                            <tr id="EndoloopPlacementTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="EndoloopPlacementCheckBox" runat="server" Checked='<%# Bind("EndoloopPlacement")%>' Text="Endoloop placement" TabIndex="16" />
                                                            </td>
                                                            <%--  <td>
                                                                <span>Performed</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="EndoloopPlacementPerformedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Successful</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="EndoloopPlacementSuccessfulRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td>
                                                                <span>Retreived</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="EndoloopPlacementRetreivedRadNumericTextBox" runat="server" TabIndex="12"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="500"
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="emrRowHide" runat="server" visible="false">
                                                <%--EMR--%>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="EmrCheckBox" runat="server" Checked='<%# Bind("EMR")%>' Text="Endoscopic" TabIndex="62" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">
                                                                <span></span>
                                                                <asp:RadioButtonList ID="EmrTypeRadioButtonList" runat="server" TabIndex="63" CssClass="rblType"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                    <asp:ListItem Value="1" Text="mucosal resection"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="submucosal dissection"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="full thickness resection"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td style="border: none;" colspan="2">
                                                                <span style="margin-left: 170px;">using
                                                                    <telerik:RadComboBox ID="EmrFluidComboBox" runat="server" Skin="Windows7" Width="100px" TabIndex="64" MarkFirstMatch="true"  />
                                                                    total volume
                                                                    <telerik:RadNumericTextBox ID="EmrFluidVolNumericTextBox" runat="server" TabIndex="65" DbValue='<%# Bind("EMRFluidVolume")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    ml
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr runat="server" id="endoRowHide" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="EndoClotCheckBox" runat="server" Checked='<%# Bind("EndoClot")%>' Text="EndoClot" TabIndex="80" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <%-- <tr id="EndoscopicResection">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="EndoscopicResectionCheckBox" runat="server" Checked='<%# Bind("EndoscopicResection")%>' Text="Endoscopic full thickness resection" TabIndex="80" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>

                                            <!-- F's -->
                                            <tr id="ForeignBodyTR">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="ForeignBodyCheckBox" runat="server" Checked='<%# Bind("ForeignBody")%>' Text="Foreign body removal" TabIndex="20" CssClass="toggleCheckBox" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="FlatusTubeInsertionTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="FlatusTubeInsertionCheckBox" runat="server" Checked='<%# Bind("FlatusTubeInsertion")%>' Text="Flatus tube insertion" TabIndex="80" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="FineNeedleAspirationTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr headrow="1" haschildrows="1">
                                                            <td rowspan="2" style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="FineNeedleAspirationCheckBox" runat="server" Text="Fine needle aspiration" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height: 23px;">
                                                            <td style="border: none; text-align: left; padding-left: 2px; vertical-align: top;">
                                                                <div class="divChildControl" style="float: left;">
                                                                    <asp:RadioButtonList ID="FineNeedleTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                        <asp:ListItem Value="1" Text="cystic lesion"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="solid lesion"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                    <br />
                                                                    <table>
                                                                        <tr>
                                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Performed:
                                                                                <telerik:RadNumericTextBox ID="FineNeedleAspirationPerformedRadNumericTextBox" runat="server" CssClass="qty-number-box"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                    <ClientEvents OnValueChanged="FNA_FNBValueChanged" />
                                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Retrieved:
                                                                                <telerik:RadNumericTextBox ID="FineNeedleAspirationRetreivedRadNumericTextBox" runat="server" CssClass="qty-number-box"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                    <ClientEvents OnValueChanged="FNA_FNBValueChanged" />
                                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Successful:
                                                                                <telerik:RadNumericTextBox ID="FineNeedleAspirationSuccessfulRadNumericTextBox" runat="server" CssClass="qty-number-box"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                    <ClientEvents OnValueChanged="FNA_FNBValueChanged" />
                                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="FineNeedleBiopsyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr headrow="1" haschildrows="1">
                                                            <td rowspan="2" style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="FineNeedleBiopsyCheckBox" runat="server" Text="Fine needle biopsy" />
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Performed:
                                                                <telerik:RadNumericTextBox ID="FineNeedleBiopsyPerformedRadNumericTextBox" runat="server" CssClass="qty-number-box"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="FNA_FNBValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Retrieved:
                                                                <telerik:RadNumericTextBox ID="FineNeedleBiopsyRetreivedRadNumericTextBox" runat="server" CssClass="qty-number-box"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="FNA_FNBValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                            <td style="border: none;">&nbsp;&nbsp;&nbsp;Successful:
                                                                <telerik:RadNumericTextBox ID="FineNeedleBiopsySuccessfulRadNumericTextBox" runat="server" CssClass="qty-number-box"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="FNA_FNBValueChanged" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>


                                            <!-- G's -->
                                            <tr id="GastrostomyInsertionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="GastrostomyInsertionCheckBox" runat="server" Checked='<%# Bind("GastrostomyInsertion")%>' Text="Gastrostomy insertion (PEG)" TabIndex="34" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">Size
                                                                <telerik:RadNumericTextBox ID="GastrostomyInsertionSizeNumericTextBox" runat="server" TabIndex="35" DbValue='<%# Bind("GastrostomyInsertionSize")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadComboBox ID="GastrostomyInsertionUnitsComboBox" runat="server" Skin="Windows7" Width="50px" TabIndex="36" MarkFirstMatch="true" />
                                                                <telerik:RadComboBox ID="GastrostomyInsertionTypeComboBox" runat="server" Skin="Windows7" Width="100px" TabIndex="37" MarkFirstMatch="true" />
                                                                <span style="margin-left: 15px;"></span>
                                                                Batch no
                                                                <telerik:RadTextBox ID="GastrostomyInsertionBatchNoTextBox" runat="server" Width="100px" Text='<%# Bind("GastrostomyInsertionBatchNo") %>' TabIndex="38" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td colspan="2" style="border: none;">
                                                                <span id="CorrectPlacementSpan" runat="server" style="margin-left: 113px;" class="jag-audit-control">
                                                                    <asp:Label ID="lblCorrectPEGPlacement" Text="Correct placement?" runat="server" For="CorrectPEGPlacementRadioButtonList" />
                                                                    <asp:RadioButtonList ID="CorrectPEGPlacementRadioButtonList" runat="server" TabIndex="39"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="No"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                    <span style="margin-left: 15px;" id="CorrectPlacementReasonSpan" runat="server">
                                                                        <asp:Label ID="lblReasonPEGPlacement" Text="Reason" runat="server" For="PEGPlacementFailureReasonTextBox" />
                                                                        <telerik:RadTextBox ID="PEGPlacementFailureReasonTextBox" runat="server" Width="180px" Text='<%# Bind("PEGPlacementFailureReason") %>' TabIndex="40" />
                                                                    </span>
                                                                </span>
                                                                <div style="float: left; padding-top: 25px">
                                                                    <telerik:RadButton ID="NPSAAlertButton" runat="server" Skin="Web20" Text="NPSA alert" OnClientClicked="showNPSAAlert" AutoPostBack="false" TabIndex="41"></telerik:RadButton>
                                                                    <script type="text/javascript">
                                                                        function showNPSAAlert() {
                                                                            var oWnd2 = $find("<%= NPSARadWindow.ClientID%>");
                                                                            var url = "<%= ResolveUrl("~/Products/Common/WordLibrary.aspx?option=NPSAAlert")%>";
                                                                            oWnd2.SetSize(620, 430);
                                                                            oWnd2._navigateUrl = url
                                                                            //Add the name of the function to be executed when RadWindow is closed.
                                                                            //oWnd2.add_close(OnClientClose);
                                                                            oWnd2.show();
                                                                        }
                                                                    </script>
                                                                </div>
                                                                <div style="float: left; padding-top: 5px; padding-left: 60px;">
                                                                    PEG outcome&nbsp;<telerik:RadComboBox ID="PEGOutcomeComboBox" runat="server" Skin="Windows7" TabIndex="41" Width="190" MarkFirstMatch="true" />
                                                                </div>
                                                                <div style="float: right; padding-top: 5px">
                                                                    <telerik:RadButton ID="PEGInstructionforcareButton" runat="server" Skin="Web20" Text="Instructions for care..." OnClick="showPEGInstruction" TabIndex="42"></telerik:RadButton>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="GastrostomyRemovalTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="GastrostomyRemovalCheckBox" runat="server" Checked='<%# Bind("GastrostomyRemoval")%>' Text="Gastrostomy removal (PEG)" TabIndex="43" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="GastricBalloonInsertionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="GastricBalloonInsertionCheckBox" runat="server" Checked='<%# Bind("GastricBalloonInsertion")%>' Text="Gastric balloon insertion" TabIndex="43" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- H's -->
                                            <tr id="HeatProbeTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="HeatProbeCheckBox" runat="server" Checked='<%# Bind("HeatProbe")%>' Text="Heater probe coagulation" TabIndex="17" CssClass="toggleCheckBox"  />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="HotBiopsyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;" class="sub-table">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="HotBiopsyCheckBox" runat="server" Checked='<%# Bind("HotBiopsy")%>' Text="Hot biopsy" TabIndex="21" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="HaemosprayTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="HaemosprayCheckBox" runat="server" Checked='<%# Bind("Haemospray")%>' Text="Haemospray" TabIndex="77" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- Homeostasis -->
                                           <tr id="homeostasisRowHide" runat="server" visible="false">
                                               <td style="padding: 0px 0px 0px 6px;">
                                                   <table style="width: 100%;">
                                                       <tr headrow="1">
                                                           <td style="border: none; width: 150px;">
                                                               <asp:CheckBox ID="HomeostasisCheckBox" runat="server" Checked='<%# Bind("Homeostasis")%>' Text="Haemeostasis" TabIndex="60" />
                                                           </td>
                                                           <td style="border: none; visibility: hidden;">  
                                                               <telerik:RadComboBox ID="HomeostasisComboBox" runat="server" Skin="Windows7" Width="130" TabIndex="61" MarkFirstMatch="true">   
                                                                 <%--   <Items>                
                                                                        <telerik:RadComboBoxItem runat="server" Text="" />
                                                                    </Items> --%>
                                                               </telerik:RadComboBox>
                              
                                                           </td>
                                                       </tr>
                                                   </table>
                                               </td>
                                           </tr>                                            


                                            <!-- I's -->
                                            <tr id="injectionRowHide" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="InjectionTherapyCheckBox" runat="server" Checked='<%# Bind("Injection")%>' Text="Injection therapy" TabIndex="21" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 50px; visibility: hidden;">
                                                                <telerik:RadComboBox ID="InjectionTypeComboBox" runat="server" Skin="Windows7" Width="130" TabIndex="22" MarkFirstMatch="true" />
                                                                &nbsp;&nbsp;&nbsp;total volume
                                                                <telerik:RadNumericTextBox ID="InjectionVolumeNumericTextBox" runat="server" TabIndex="23" DbValue='<%# Bind("InjectionVolume")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                ml &nbsp;&nbsp;&nbsp;via
                                                                <telerik:RadNumericTextBox ID="InjectionNumberNumericTextBox" runat="server" TabIndex="24" DbValue='<%# Bind("InjectionNumber")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                injections                                                                
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- M's -->
                                            <tr runat="server" id="markingRowHide" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 100px;">
                                                                <asp:CheckBox ID="MarkingCheckBox" runat="server" Checked='<%# Bind("Marking")%>' Text="Marking" TabIndex="78" />
                                                            </td>
                                                            <td style="border: none; width: 150px; visibility: hidden;">
                                                                <telerik:RadComboBox ID="MarkingTypeComboBox" runat="server" Skin="Windows7" Width="100px" TabIndex="79" MarkFirstMatch="true" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <span>Performed</span>&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="MarkedQtyNumericTextBox" runat="server" TabIndex="80" DbValue='<%# Bind("MarkedQuantity")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <br />
                                                                <%--</td>
                                                            <td style="border: none; width: 350px;">--%>
                                                                <span>Location:</span>
                                                                <span>
                                                                    <asp:CheckBox ID="chkTattooLocationDistal" runat="server" Checked='<%# Bind("TattooLocationDistal")%>' Text="Distal" TabIndex="78" />&nbsp;
                                                                </span>
                                                                <span>
                                                                    <asp:CheckBox ID="chkTattooLocationProximal" runat="server" Checked='<%# Bind("TattooLocationProximal")%>' Text="Proximal" TabIndex="78" />&nbsp;
                                                                </span>  
                                                            </td>

                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- N's -->
                                            <tr id="NGNJTubeInsertionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="NGNJTubeCheckBox" runat="server" Checked='<%# Bind("NGNJTubeInsertion")%>' Text="NG/NJ tube insertion" TabIndex="44" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">Nostril
                                                                <asp:RadioButtonList ID="NGNJTubeInsertionRadioButtonList" runat="server" TabIndex="32"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                    <asp:ListItem Value="1" Text="Right"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="Left"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td style="border: none;" />
                                                            <td style="border: none;">Length of tube at nostril 
                                                                <telerik:RadNumericTextBox ID="NGNJTubeInsertionLengthNumericTextBox" runat="server" TabIndex="35" DbValue='<%# Bind("NGNJTubeInsertionLength")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" />
                                                                </telerik:RadNumericTextBox>
                                                                cm<br />
                                                                <asp:CheckBox ID="NGNJTubeInsertionBridle" runat="server" Checked='<%# Bind("NGNJTubeInsertionBridle")%>' Text="Bridle used" TextAlign="Left" TabIndex="29" /><br />
                                                                Batch no<telerik:RadTextBox ID="NGNJTubeInsertionBatchNoTextBox" runat="server" Width="100px" Text='<%# Bind("NGNJTubeInsertionBatchNo") %>' TabIndex="38" />
                                                           <div style="padding-top: 10px;text-align:end">
                  
                                                          <telerik:RadButton ID="NGInstructionforcareButton" runat="server" Skin="Web20" Text="Instructions for care..." OnClick="showPEGInstruction" TabIndex="42"></telerik:RadButton>
                                                        </div>
                                                        </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- O's -->
                                            <tr id="OesophagealDilatationTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;" valign="top">
                                                                <asp:CheckBox ID="OesophagealDilatationCheckBox" runat="server" Checked='<%# Bind("OesophagealDilatation")%>' Text="Oesophageal dilatation" TabIndex="25" />
                                                            </td>
                                                            <td style="border: none; padding-right: 30px; visibility: hidden;">Dilated to &nbsp;
                                                                <%--added by rony tfs-4085--%>
                                                                <telerik:RadNumericTextBox ID="DilatedToTextBox" runat="server" TabIndex="26" DbValue='<%# Bind("DilatedTo")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.1"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>
                                                                <telerik:RadComboBox ID="DilatationUnitsComboBox" runat="server" Skin="Windows7" Width="50" TabIndex="27" MarkFirstMatch="true" />
                                                                <telerik:RadComboBox ID="DilatorTypeComboBox" runat="server" Skin="Windows7" Width="130" TabIndex="28" MarkFirstMatch="true" />
                                                                <asp:CheckBox ID="ScopePassCheckBox" runat="server" Checked='<%# Bind("DilatorScopePass")%>' Text="scope could pass" TextAlign="Left" TabIndex="29" /><br />
                                                                <div style="padding-top: 10px;">
                                                                    <%--added by rony tfs-3833 start--%>
                                                                    <span>Dilatation leading to perforation</span>
                                                                   <asp:RadioButtonList runat="server" ID="PerforationRadioButtonList" CssClass="rbl rbl-confirmed"
                                                                        CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                        <asp:ListItem Value="1">Yes</asp:ListItem>
                                                                        <asp:ListItem Value="0">No</asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                    <%--end--%>
                                                                    <telerik:RadButton ID="OesoInstructionforCareButton" runat="server" Text="Instructions for care..." OnClick="showInstruction" AutoPostBack="true" Skin="Web20" Style="display: none" TabIndex="30" />

                                                                    <script type="text/javascript">
                                                                        function showInst() {
                                                                            var oWnd1 = $find("<%= RadWindow1.ClientID%>");
                                                                            oWnd.show();
                                                                        }
                                                                    </script>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>


                                            <!-- P's -->
                                            <tr id="ProbeInsertionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 80%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; vertical-align: top; width: 130px;">
                                                                <asp:CheckBox ID="PH_ProbeInsertionCheckBox" runat="server" Checked='<%# Bind("pHProbeInsert")%>' Text="pH probe insertion" TabIndex="73" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 2px; vertical-align: top; width: 180px; visibility: hidden;">probe inserted at &nbsp;
                                                                <telerik:RadNumericTextBox ID="ProbeInsertedAtNumericTextBox" runat="server" TabIndex="74" DbValue='<%# Bind("pHProbeInsertAt")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>cm
                                                                 
                                                            </td>
                                                            <td style="border: none; text-align: left; padding: 0px 0px;">
                                                                <div>
                                                                    <table style="width: 100%;">
                                                                        <tr headrow="1" haschildrows="1">
                                                                            <td style="border: none; text-align: left; vertical-align: top;">
                                                                                <asp:CheckBox ID="EndoscopicCheck" runat="server" Checked='<%# Bind("pHProbeInsertChk")%>' Text="Endoscopic check" TextAlign="Left" TabIndex="75" />
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td style="border: none; text-align: left;">top of probe&nbsp;
                                                                                <telerik:RadNumericTextBox ID="TopOfProbeNumericTextBox" runat="server" TabIndex="76" DbValue='<%# Bind("pHProbeInsertChkTopTo")%>'
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>cm      
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="PancolonicDyeSprayTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="PancolonicDyeSprayCheckBox" runat="server" Checked='<%# Bind("PancolonicDyeSpray")%>' Text="Pancolonic dye spray" TabIndex="80" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="PhotodynamicTherapyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PDTCheckbox" runat="server" Text="Photodynamic Therapy (PDT)" />
                                                            </td>
                                                            <td style="border: none; text-align: left; padding-right: 50px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="PolypectomyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PolypectomyCheckBox" runat="server" Checked='<%# Bind("Polypectomy")%>' Text="Polypectomy" TabIndex="31" Enabled="false" />
                                                            </td>
                                                            <td style="border: none; text-align: left; visibility: hidden;">
                                                                <telerik:RadNumericTextBox ID="PolypectomyQtyRadNumericTextBox" runat="server" Enabled="false" TabIndex="26" DbValue='<%# Bind("PolypectomyQty")%>'
                                                                    Width="50px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox></td>
                                                            <td style="border: none; text-align: left;">
                                                                <telerik:RadButton ID="EnterPolypDetailsRadButton" runat="server" Text="Retrieval details..." Skin="Windows7" CssClass="poly-details-btn" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height: 23px; display: none;" runat="server" visible="false">
                                                            <td colspan="2" style="border: none; text-align: right; padding-right: 8px;">
                                                                <asp:RadioButtonList ID="PolypectomyRemovalTypeRadioButtonList" runat="server" TabIndex="33"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType polypRemovalTypeList">
                                                                    <asp:ListItem Value="1" Text="partial snare"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="cold snare"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="hot snare cauterisation"></asp:ListItem>
                                                                    <asp:ListItem Value="6" Text="EMR by hot snare"></asp:ListItem>
                                                                    <asp:ListItem Value="4" Text="hox bx"></asp:ListItem>
                                                                    <asp:ListItem Value="5" Text="cold bx"></asp:ListItem>
                                                                    <asp:ListItem Value="7" Text="EMR by cold snare"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="PhotodynamicTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="chkPhotoDynamicTherapy" runat="server" Checked='<%# Bind("PhotoDynamicTherapy")%>' Text="Photodynamic Therapy (PDT)" TabIndex="60" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="PyloricDilatationTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 200px;">
                                                                <asp:CheckBox ID="PyloricDilatationChekBox" runat="server" Checked='<%# Bind("PyloricDilatation")%>' Text="Pyloric/duodenal dilatation" TabIndex="44" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">Dilatation leading to perforation?
                                                                <asp:RadioButtonList runat="server" ID="PyloricLeadingToPerforationRadioButton" CssClass="rbl rbl-confirmed"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                    <asp:ListItem Value="1">Yes</asp:ListItem>
                                                                    <asp:ListItem Value="2">No</asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- R's -->
                                            <tr id="RadioFrequencyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="RFACheckBox" runat="server" Checked='<%# Bind("RFA")%>' Text="Radio Frequency Ablation" TabIndex="66" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 250px; visibility: hidden;">
                                                                <asp:RadioButtonList ID="RFATypeRadioButtonList" runat="server" TabIndex="67"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                    <asp:ListItem Value="1" Text="Circumferential"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="Focal"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td colspan="2" style="border: none;">
                                                                <div id="RFADiv" runat="server" style="float: left; padding-left: 165px;">
                                                                    Treatment from
                                                                    <telerik:RadNumericTextBox ID="RFATreatmentFromNumericTextBox" runat="server" TabIndex="68" DbValue='<%# Bind("RFATreatmentFrom")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    to
                                                                    <telerik:RadNumericTextBox ID="RFATreatmentToNumericTextBox" runat="server" TabIndex="69" DbValue='<%# Bind("RFATreatmentTo")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    cm from incisors
                                                                    <div style="padding-top: 8px;"></div>
                                                                    Energy delivered
                                                                    <telerik:RadNumericTextBox ID="RFAEnergyDeliveredNumericTextBox" runat="server" TabIndex="70" DbValue='<%# Bind("RFAEnergyDel")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="55px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    Joules
                                                                    <div style="padding-top: 8px;"></div>
                                                                    <span class="RFANumSegTreatedSpan">No. of segments treated (1 to 40)</span>
                                                                    <telerik:RadNumericTextBox ID="RFASegmentsTreatedNumericTextBox" runat="server" TabIndex="71" DbValue='<%# Bind("RFANumSegTreated")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0"
                                                                        MaxValue="40">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    <div style="padding-top: 8px;"></div>
                                                                    <span class="RFANumTimesSegTreatedSpan">No. of times each segment treated (1-4)</span>
                                                                    <telerik:RadNumericTextBox ID="NoTimesSegmentTreatedNumericTextBox" runat="server" TabIndex="72" DbValue='<%# Bind("RFANumTimesSegTreated")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0"
                                                                        MaxValue="4">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                </div>
                                                            </td>
                                                        </tr>

                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- S's -->
                                            <tr id="SigmoidopexyTR" runat="server" visible="false">
                                                <%--Sigmoidopexy: COLON Specific field--%>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td valign="top" style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="SigmoidopexyCheckBox" runat="server" Text="Sigmoidopexy" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">
                                                                <span></span>
                                                                qty
                                                                <telerik:RadNumericTextBox ID="SigmoidopexyQtyNumericBox" runat="server"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                make
                                                                <telerik:RadComboBox ID="SigmoidopexyMakeComboBox" runat="server" Skin="Windows7" Width="100px" MarkFirstMatch="True" />
                                                                <br />
                                                                <fieldset id="SigmoidopexyFieldset" runat="server" style="border: #83AABA solid 0; padding: 10px; float: left; width: 200px;">
                                                                    <legend>Ward instructions</legend>
                                                                    <div>
                                                                        <div style="clear: both; margin-bottom: 5px;">
                                                                            <div style="width: 100px; float: left;">
                                                                                <asp:CheckBox ID="SigmoidopexyClearFluidsCheckBox" runat="server" Text="Clear fluids for" Visible="False" />
                                                                                <asp:Label Text="Clear fluids for" runat="server" For="SigmoidopexyFluidDaysRadNumeric" />
                                                                            </div>
                                                                            <div>
                                                                                <telerik:RadNumericTextBox ID="SigmoidopexyFluidDaysRadNumeric" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="45px"
                                                                                    MinValue="0" NumberFormat-DecimalDigits="0" DataType="System.Int16" />
                                                                                days
                                                                            </div>
                                                                        </div>
                                                                        <div>
                                                                            <div style="width: 100px; float: left;">
                                                                                <asp:CheckBox ID="SigmoidopexyAntibioticsCheckBox" runat="server" Text="Antibiotics for" Style="width: 100px" Visible="False" />
                                                                                <asp:Label Text="Antibiotics for" for="SigmoidopexyAtibioticDaysRadNumeric" runat="server" />
                                                                            </div>
                                                                            <div>
                                                                                <telerik:RadNumericTextBox ID="SigmoidopexyAtibioticDaysRadNumeric" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="45px"
                                                                                    MinValue="0" NumberFormat-DecimalDigits="0" DataType="System.Int16" />
                                                                                days
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </fieldset>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="StentInsertionTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%; border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="StentInsertionCheckBox" runat="server" Checked='<%# Bind("StentInsertion")%>' Text="Stent insertion" TabIndex="52" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">&nbsp;&nbsp;&nbsp;qty
                                                            <telerik:RadNumericTextBox ID="StentInsertionQtyNumericTextBox" runat="server" TabIndex="53" DbValue='<%# Bind("StentInsertionQty")%>'
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>

                                                                &nbsp;&nbsp;&nbsp;type
                                                            <telerik:RadComboBox ID="StentInsertionTypeComboBox" runat="server" Skin="Windows7" Width="100" TabIndex="54" MarkFirstMatch="true" />

                                                                &nbsp;&nbsp;&nbsp;length
                                                            <telerik:RadNumericTextBox ID="StentInsertionLengthNumericTextBox" runat="server" TabIndex="55" DbValue='<%# Bind("StentInsertionLength")%>'
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                                cm

                                                            &nbsp;&nbsp;&nbsp;dia.
                                                            <telerik:RadNumericTextBox ID="StentInsertionDiaNumericTextBox" runat="server" TabIndex="56" DbValue='<%# Bind("StentInsertionDiameter")%>'
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>

                                                                <telerik:RadComboBox ID="StentInsertionDiaUnitsComboBox" runat="server" Skin="Windows7" Width="50px" TabIndex="57" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td colspan="2" style="border: none;">
                                                                <span style="margin-left: 133px;">Batch no
                                                                    <telerik:RadTextBox ID="StentInsertionBatchNoTextBox" runat="server" Width="100px" Text='<%# Bind("StentInsertionBatchNo") %>' TabIndex="58" />
                                                                    &nbsp;
                                                                    <asp:CheckBox ID="MetalicStentCheckBox" runat="server" Checked='<%# Bind("MetalicStent")%>' Text="Metallic" TextAlign="Left" TabIndex="29" />
                                                                </span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="border: none;">
                                                                <table width="100%">
                                                                    <tr>
                                                                        <td style="text-align: left; border: none; width: 440px;">
                                                                            <div id="divStentCorrectPlacement" class="correct-placement jag-audit-control" runat="server" visible="false">
                                                                                <%-- if 'Duct' is selected as an Abnormaility then "Stent Placement Correctly" should displayed --%>
                                                                                <asp:Label runat="server" for="StentCorrectPlacementRadioButton">Correct placement across stricture: </asp:Label>
                                                                                <asp:RadioButtonList ID="StentCorrectPlacementRadioButton" runat="server" CellSpacing="0" CellPadding="0"
                                                                                    RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                                    <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                                    <asp:ListItem Value="0" Text="No"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                                <div class="incorrect-placement-reason" style="display: none; padding-left: 35px; padding-top: 5px;">
                                                                                    <asp:Label runat="server">Reason:&nbsp;</asp:Label>
                                                                                    <asp:RadioButtonList ID="FailedPlacementReasonsRadioButtonList" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType" />
                                                                                </div>
                                                                            </div>
                                                                        </td>
                                                                        <td style="border: none;" valign="top">
                                                                            <telerik:RadButton ID="StentInstructionForCareButton" runat="server" Text="Instructions for care..." AutoPostBack="true" Skin="Web20" Style="display: none" OnClick="showInstruction" TabIndex="59" />
                                                                        </td>
                                                                    </tr>
                                                                </table>

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="StentRemovalTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="StentRemovalCheckBox" runat="server" Checked='<%# Bind("StentRemoval")%>' Text="Stent removal" TabIndex="60" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">technique&nbsp;
                                                                <telerik:RadComboBox ID="StentRemovalTechniqueComboBox" runat="server" Skin="Windows7" Width="100px" TabIndex="61" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- V's -->
                                            <tr id="VaricealSclerotherapyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="VaricealSclerotherapyCheckBox" runat="server" Checked='<%# Bind("VaricealSclerotherapy")%>' Text="Variceal sclerotherapy" TabIndex="45" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">
                                                                <telerik:RadComboBox ID="VaricealScleroInjTypeComboBox" runat="server" Skin="Windows7" Width="130" TabIndex="46" MarkFirstMatch="true" />

                                                                &nbsp;&nbsp;&nbsp;total volume
                                                                <telerik:RadNumericTextBox ID="VaricealScleroInjVolNumericTextBox" runat="server" TabIndex="47" DbValue='<%# Bind("VaricealSclerotherapyInjectionVol")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                ml &nbsp;&nbsp;&nbsp;via
                                                                <telerik:RadNumericTextBox ID="VaricealScleroInjNumNumericTextBox" runat="server" TabIndex="48" DbValue='<%# Bind("VaricealSclerotherapyInjectionNum")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                injections
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="VaricealBandingTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="VaricealBandingCheckBox" runat="server" Checked='<%# Bind("VaricealBanding")%>' Text="Variceal banding" TabIndex="49" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">&nbsp;&nbsp;&nbsp;No of bands
                                                                <telerik:RadNumericTextBox ID="VaricealBandingNumNumericTextBox" runat="server" TabIndex="50" DbValue='<%# Bind("VaricealBandingNum")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="VaricealClipTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="VaricealClipCheckBox" runat="server" Checked='<%# Bind("VaricealClip")%>' Text="Variceal clip" TabIndex="51" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="ValveTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1">
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="chkValve" runat="server" Checked='<%# Bind("Valve")%>' Text="Valve" TabIndex="60" />
                                                            </td>
                                                            <td style="border: none; visibility: hidden;">qty&nbsp;
                                                               <telerik:RadNumericTextBox ID="ValveQty" runat="server" TabIndex="53" DbValue='<%# Bind("ValveQty")%>'
                                                                   IncrementSettings-InterceptMouseWheel="false"
                                                                   IncrementSettings-Step="1"
                                                                   Width="35px"
                                                                   MinValue="0">
                                                                   <NumberFormat DecimalDigits="0" />
                                                               </telerik:RadNumericTextBox>
                                                                &nbsp;&nbsp;&nbsp;type
                                                            <telerik:RadComboBox ID="cboValveType" runat="server" Skin="Windows7" Width="150" DropDownAutoWidth="Enabled" TabIndex="54" MarkFirstMatch="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <!-- Y's -->
                                            <tr id="YAGLaserTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; vertical-align: top">
                                                                <asp:CheckBox ID="YagLaserCheckBox" runat="server" Checked='<%# Bind("YagLaser")%>' Text="YAG laser" TabIndex="2" CssClass="toggleCheckBox" />
                                                            </td>
                                                            <td style="border: none; text-align: right; padding-right: 50px; visibility: hidden;">
                                                                <telerik:RadNumericTextBox ID="YagLaserWattsNumericTextBox" runat="server" TabIndex="3" DbValue='<%# Bind("YagLaserWatts")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateYagLaserKJ" />
                                                                </telerik:RadNumericTextBox>W&nbsp;&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="YagLaserPulsesNumericTextBox" runat="server" TabIndex="4" DbValue='<%# Bind("YagLaserPulses")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="10"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                    <ClientEvents OnValueChanged="UpdateYagLaserKJ" />
                                                                </telerik:RadNumericTextBox>pulses&nbsp;&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="YagLaserSecsNumericTextBox" runat="server" TabIndex="5" DbValue='<%# Bind("YagLaserSecs")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="0.5"
                                                                    Width="45px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="1" AllowRounding="false" />
                                                                    <ClientEvents OnValueChanged="UpdateYagLaserKJ" />
                                                                </telerik:RadNumericTextBox>sec&nbsp;&nbsp;&nbsp;
                                                                <telerik:RadNumericTextBox ID="YagLaserKJNumericTextBox" runat="server" TabIndex="6" DbValue='<%# Bind("YagLaserKJ")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step=".5"
                                                                    Width="55px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                                                                </telerik:RadNumericTextBox>kJ
                                                                <br />
                                                                <br />
                                                                <telerik:RadButton ID="YagInstructionForCareRadButton" runat="server" Text="Instructions for care..." AutoPostBack="true" OnClick="showYagInstruction" Skin="Web20" Style="display: none" TabIndex="7" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>

                    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
                        <Windows>
                            <telerik:RadWindow ID="NPSARadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="850px" Height="750px" VisibleStatusbar="false" />
                        </Windows>
                        <Windows>
                            <telerik:RadWindow ID="RadWindow1" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="600px" Height="210px" Title="Post procedure patient care" VisibleStatusbar="false" Modal="True" Skin="Metro">
                                <ContentTemplate>
                                    <table id="table3" runat="server" cellspacing="0" cellpadding="0" border="0" style="padding-left: 15px; padding-top: 15px;">
                                        <tr>
                                            <td colspan="2" style="border: none;">
                                                <table>
                                                    <tr>
                                                        <th style="border: none; text-align: left;">
                                                            <asp:CheckBox ID="OesoDilNilByMouthCheckBox" runat="server" onclick="checkBoxOesoDilNilClicked();" Text="Nil by mouth for" AutoPostBack="false" TabIndex="83" />
                                                        </th>
                                                        <th style="border: none; text-align: left;">
                                                            <telerik:RadNumericTextBox ID="OesoDilNilByMouthHrsRadNumericTextBox" runat="server"  AutoPostBack="false" TabIndex="84"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0"
                                                                ClientEvents-OnValueChanged="NBM_numericTextBoxValueChanged"> <%-- edited by mostafiz issue 4214 --%>
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>

                                                        <th style="border: none; text-align: left; padding-left: 35px;">
                                                            <asp:CheckBox ID="OesoDilWarmFluidsCheckBox" runat="server" onclick="checkBoxOesoDilWarmClicked();" Text="Warm fluids only" TabIndex="85" />
                                                        </th>
                                                        <th style="border: none;">
                                                            <telerik:RadNumericTextBox ID="OesoDilWarmFluidsHrsRadNumericTextBox" runat="server" TabIndex="86"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0"
                                                                ClientEvents-OnValueChanged="WFO_numericTextBoxValueChanged"> <%-- edited by mostafiz issue 4214 --%>
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <th style="border: none; width: 140px; text-align: left;">
                                                            <asp:CheckBox ID="OesoDilXRayCheckBox" runat="server" onclick="checkBoxOesoDilXRayClicked();" Text="Chest X-ray after" TabIndex="87" />
                                                        </th>
                                                        <th style="border: none;">
                                                            <telerik:RadNumericTextBox ID="OesoDilXRayHrsRadNumericTextBox" runat="server" TabIndex="88"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0"
                                                                ClientEvents-OnValueChanged="CXR_numericTextBoxValueChanged"> <%-- edited by mostafiz issue 4214 --%>
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>
                                                        <th style="border: none; text-align: left; padding-left: 35px;">
                                                            <asp:CheckBox ID="OesoDilSoftDietCheckBox" runat="server" onclick="checkBoxOesoDilSoftClicked();" Text="Soft diet for" TabIndex="89" />
                                                        </th>
                                                        <th style="border: none; text-align: left;">
                                                            <telerik:RadNumericTextBox ID="OesoDilSoftDietDaysRadNumericTextBox" runat="server" TabIndex="90"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0"
                                                                ClientEvents-OnValueChanged="SDF_numericTextBoxValueChanged"> <%-- edited by mostafiz issue 4214 --%>
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">days</span>
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <th colspan="2" style="border: none; text-align: left;">
                                                            <asp:CheckBox ID="OesoDilMedicalReviewCheckBox" runat="server" TabIndex="91"
                                                                Text="Medical review before discharge" />
                                                        </th>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 5px; padding-top: 18px;">
                                                <div id="buttonsdivwindow1" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central;">
                                                    <telerik:RadButton ID="savewindowbutton" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" TabIndex="92" Icon-PrimaryIconCssClass="telerikOkButton" OnClick="SaveAndCloseWindow" ValidationGroup="SaveTherapeuticProcedure" />
                                                    <telerik:RadButton ID="cancelwindowbutton" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow1" TabIndex="93" Icon-PrimaryIconCssClass="telerikCancelButton" />

                                                    <telerik:RadNotification ID="SaveTherapeuticProcedureRadNotification" runat="server" Animation="None"
                                                        EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                                        LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                                                        AutoCloseDelay="70000">
                                                        <ContentTemplate>
                                                            <asp:ValidationSummary ID="SaveTherapeuticProcedureValidationSummary" runat="server" ValidationGroup="SaveTherapeuticProcedure" DisplayMode="BulletList"
                                                                EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                                        </ContentTemplate>
                                                    </telerik:RadNotification>

                                                    <script type="text/javascript">
                                                        function CheckForValidPage(button) {
                                                            var valid = Page_ClientValidate("SaveTherapeuticProcedure");
                                                            if (!valid) {
                                                                $find("<%=SaveTherapeuticProcedureRadNotification.ClientID%>").show();
                                                            }
                                                        }

                                                        function closeWindow1() {
                                                            var oWnd = $find("<%= RadWindow1.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="RadWindow2" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="500px" Height="240px" Title="YAG laser treatment instructions for care" VisibleStatusbar="false" Modal="true" Skin="Metro" OnLoad="YAGLaser_Load">
                                <ContentTemplate>
                                    <table id="table1" runat="server" border="0" style="padding-left: 15px; padding-top: 15px;">
                                        <tr>
                                            <td colspan="2" style="border: none;">
                                                <table>
                                                    <tr>
                                                        <th style="border: none; width: 150px; text-align: left;">
                                                            <asp:CheckBox ID="YAGDilNilByMouthCheckBox" runat="server" Text="Nil by mouth for" AutoPostBack="false" TabIndex="94" />
                                                        </th>
                                                        <th style="border: none; text-align: left;">
                                                            <telerik:RadNumericTextBox ID="YAGDilNilByMouthHrsRadNumericTextBox" runat="server" AutoPostBack="false" TabIndex="95"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="45px"
                                                                MinValue="0" Value="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="font-weight: normal;">hours</span>
                                                        </th>
                                                        <tr>
                                                            <tr>
                                                                <th style="border: none; width: 150px; text-align: left;">
                                                                    <asp:CheckBox ID="YagDilWarmFluidsCheckBox" runat="server" Text="Warm fluids only" TabIndex="96" />
                                                                </th>
                                                                <th style="border: none; text-align: left;">
                                                                    <telerik:RadNumericTextBox ID="YagDilWarmFluidsHrsRadNumericTextBox" runat="server" TabIndex="97"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="45px"
                                                                        MinValue="0" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    <span style="font-weight: normal;">hours</span>
                                                                </th>
                                                            </tr>
                                                            <tr>
                                                                <th style="border: none; width: 150px; text-align: left;">
                                                                    <asp:CheckBox ID="YagDilSoftDietCheckBox" runat="server" Text="Soft diet for" TabIndex="98" />
                                                                </th>
                                                                <th style="border: none; text-align: left;">
                                                                    <telerik:RadNumericTextBox ID="YagDilSoftDietDaysRadNumericTextBox" runat="server" TabIndex="99"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="60px"
                                                                        MinValue="0" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    <span style="font-weight: normal;">days</span>
                                                                </th>
                                                            </tr>
                                                            <tr>
                                                                <th colspan="2" style="border: none; width: 150px; text-align: left;">
                                                                    <asp:CheckBox ID="YagDilMedicalReviewCheckBox" runat="server" TabIndex="100"
                                                                        Text="Medical review before discharge" />
                                                                </th>
                                                            </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px; padding-top: 18px;">
                                                <div id="buttonsdivwindow2">
                                                    <telerik:RadButton ID="Window2SaveRadButton" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" TabIndex="101" Icon-PrimaryIconCssClass="telerikOkButton" />
                                                    <!--OnClick="SaveAndCloseYagWindow"-->
                                                    <telerik:RadButton ID="Window2CancelRadButton" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow2" TabIndex="102" Icon-PrimaryIconCssClass="telerikCancelButton" />
                                                    <script type="text/javascript">
                                                        function closeWindow2() {
                                                            var oWnd = $find("<%= RadWindow2.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            location.reload();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="RadWindow3" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="680px" Height="220px" Title="Insertion instructions for care" VisibleStatusbar="false" Modal="true" Skin="Metro" OnClientClose="closeWindow3">
                                <ContentTemplate>
                                    <table id="tablepeg" runat="server" border="0">
                                        <tr id="pegInsertionRowHide" runat="server">
                                            <td>
                                                <fieldset id="PEGInsertionFieldset" runat="server" style="margin-left: 30px; border: #83AABA solid 1px;">
                                                    <legend>PEG Insertion instructions for care</legend>
                                                    <div>
                                                        <asp:CheckBox ID="NilByMouthCheckBox" runat="server" Checked='<%# Bind("NilByMouth")%>' Text="Nil by mouth for" TabIndex="103" />
                                                        <telerik:RadNumericTextBox ID="NilByMouthHrsNumericTextBox" runat="server" TabIndex="104" DbValue='<%# Bind("NilByMouthHrs")%>'
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        hrs

                                            &nbsp;&nbsp;&nbsp;&nbsp;
                                            <asp:CheckBox ID="NilByProcCheckBox" runat="server" Checked='<%# Bind("NilByProc")%>' Text="Nil by PEG for" TabIndex="105" />
                                                        <telerik:RadNumericTextBox ID="NilByProcHrsNumericTextBox" runat="server" TabIndex="106" DbValue='<%# Bind("NilByProcHrs")%>'
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                        hrs

                                                                        &nbsp;&nbsp;&nbsp;&nbsp;
                                                                        Flange position
                                                                        <telerik:RadNumericTextBox ID="FlangePositionNumericTextBox" runat="server" TabIndex="107" DbValue='<%# Bind("FlangePosition")%>'
                                                                            IncrementSettings-InterceptMouseWheel="false"
                                                                            IncrementSettings-Step=".01"
                                                                            Width="35px"
                                                                            MinValue="0">
                                                                            <NumberFormat DecimalDigits="2" />
                                                                        </telerik:RadNumericTextBox>
                                                        cm
                                                    </div>
                                                    <br />
                                                    <div>
                                                        <asp:CheckBox ID="AttachmentToWardCheckBox" runat="server" Checked='<%# Bind("AttachmentToWard")%>'
                                                            Text="All attachments for feeding returned to the ward with patient" TabIndex="108" />
                                                    </div>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="buttonsdivwindow3">
                                                    <br />
                                                    <br />
                                                    <telerik:RadButton ID="RadButton1" runat="server" Text="Confirm" Skin="Web20" AutoPostBack="true" OnClick="SaveAndCloseGEJWindow" TabIndex="109" />
                                                    <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" OnClientClicked="closeWindow3" TabIndex="110" />
                                                    <script type="text/javascript">
                                                        function closeWindow3() {
                                                            var oWnd = $find("<%= RadWindow3.ClientID%>");
                                                            if (oWnd != null)
                                                                oWnd.close();
                                                            location.reload();
                                                            return false;
                                                        }
                                                    </script>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new entry"
                                KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                                <ContentTemplate>
                                    <table cellspacing="3" cellpadding="3" style="width: 100%">
                                        <tr>
                                            <td>
                                                <br />
                                                <div class="left">
                                                    <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                                    <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                                    &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </telerik:RadWindow>
                            <telerik:RadWindow ID="PolypDetailsRadWindow" runat="server" ReloadOnShow="true" InitialBehaviors="Maximize" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" VisibleStatusbar="false" Modal="True" Skin="Metro">
                            </telerik:RadWindow>
                        </Windows>
                    </telerik:RadWindowManager>
                    <%--</form>--%>
                    <script type="text/javascript">

                        var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
                        var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";
                        var clicks = 0;

                        /* edited by mostafiz issue --> 4214 */

                        function checkBoxOesoDilNilClicked() {
                            var checkBox = document.getElementById('<%= OesoDilNilByMouthCheckBox.ClientID %>');
                            if (checkBox.checked) {
                                $("#<%= OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("4");
                            } else {
                                $("#<%= OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("0");
                            }
                        }
                        function checkBoxOesoDilXRayClicked() {
                            var checkBox = document.getElementById('<%= OesoDilXRayCheckBox.ClientID %>');
                            if (checkBox.checked) {
                                $("#<%= OesoDilXRayHrsRadNumericTextBox.ClientID%>").val("4");
                            } else {
                                $("#<%= OesoDilXRayHrsRadNumericTextBox.ClientID%>").val("0");
                            }
                        }
                        function checkBoxOesoDilSoftClicked() {
                            var checkBox = document.getElementById('<%= OesoDilSoftDietCheckBox.ClientID %>');
                            if (checkBox.checked) {
                                $("#<%= OesoDilSoftDietDaysRadNumericTextBox.ClientID%>").val("4");
                        } else {
                                $("#<%= OesoDilSoftDietDaysRadNumericTextBox.ClientID%>").val("0");
                            }
                        }
                        function checkBoxOesoDilWarmClicked() {
                            var checkBox = document.getElementById('<%= OesoDilWarmFluidsCheckBox.ClientID %>');
                            if (checkBox.checked) {
                                $("#<%= OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("4");
                            } else {
                                $("#<%= OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("0");
                            }
                        }

                        function NBM_numericTextBoxValueChanged(sender, args) {
                            var numericValue = sender.get_value(); 
                            var checkbox = $('#<%= OesoDilNilByMouthCheckBox.ClientID %>');                            
                            if(numericValue>0 && !checkbox.is(':checked')) {
                               checkbox.prop('checked', true);                               
                            }                          
                        }

                        function WFO_numericTextBoxValueChanged(sender, args) {
                            var numericValue = sender.get_value();
                            var checkbox = $('#<%= OesoDilWarmFluidsCheckBox.ClientID %>');                         
                             if(numericValue>0 && !checkbox.is(':checked')) {
                                checkbox.prop('checked', true);                               
                             }                             
                        }

                        function CXR_numericTextBoxValueChanged(sender, args) {
                            var numericValue = sender.get_value(); 
                            var checkbox = $('#<%= OesoDilXRayCheckBox.ClientID %>');
                            if(numericValue>0 && !checkbox.is(':checked')) {
                               checkbox.prop('checked', true);                               
                            }                           
                        }

                        function SDF_numericTextBoxValueChanged(sender, args) {
                            var numericValue = sender.get_value();
                            var checkbox = $('#<%= OesoDilSoftDietCheckBox.ClientID %>');
                             if(numericValue>0 && !checkbox.is(':checked')) {
                               checkbox.prop('checked', true);                               
                            }                           
                        }

                        /* edited by mostafiz issue --> 4214 */


                        function UpdateYagLaserKJ(sender, eventArgs) {
                            if (event != undefined) {
                                var currentControl = event.target;
                                console.log("function UpdateYagLaserKJ: currentUc ==> " + currentControl.id);

                                var YagLaserWatts = $.trim($('YagLaserWattsNumericTextBox').val());
                                var YagLaserPulses = $.trim($('YagLaserPulsesNumericTextBox').val());
                                var YagLaserSecs = $.trim($('YagLaserSecsNumericTextBox').val());
                                if ((YagLaserWatts == '') || (YagLaserPulses == '') || (YagLaserSecs == '')) {
                                    $('YagLaserKJNumericTextBox').val(0);
                                } else {
                                    $('YagLaserKJNumericTextBox').val((YagLaserWatts * YagLaserPulses * YagLaserSecs) / 1000);
                                }
                            }
                        }

                        function saveButtonClicked(button, args) {
                            /*Added by rony tfs-3833*/
                            //if ($("#OesophagealDilatationCheckBox").is(':checked')) {
                            //    var vPerforation = $("#PerforationRadioButtonList").find(":checked").val();
                            //    if (vPerforation != 0 && vPerforation != 1) {
                            //        alert('Please select a value to state if there was perforation.');
                            //        args.set_cancel(true);
                            //    }
                            //} else {
                            //    disableSaveButton();
                            //    validatePage();
                            //}                            
                        }

                        function disableSaveButton() {
                            //This will stop Clicky McClickface clicking on the save button over and over again causing multiple records to be created in the database
                            clicks = clicks + 1;
                            if (clicks == 1)
                                return true;
                            else {
                                $('#SaveButton').prop('disabled', true);
                                return false;
                            }
                        }

                        function UpdateArgonBeamKJ(sender, eventArgs) {
                            if (event != undefined) {
                                var currentControl = event.target;


                                var ArgonBeamDiathermyWatts = $.trim($('ArgonBeamDiathermyWattsNumericTextBox').val());
                                var ArgonBeamDiathermyPulses = $.trim($('ArgonBeamDiathermyPulsesNumericTextBox').val());
                                var ArgonBeamDiathermySecs = $.trim($('ArgonBeamDiathermySecsNumericTextBox').val());
                                if ((ArgonBeamDiathermyWatts == '') || (ArgonBeamDiathermyPulses == '') || (ArgonBeamDiathermySecs == '')) {
                                    $('ArgonBeamDiathermyKJNumericTextBox').val(0);
                                } else {
                                    $('ArgonBeamDiathermyKJNumericTextBox').val((ArgonBeamDiathermyWatts * ArgonBeamDiathermyPulses * ArgonBeamDiathermySecs) / 1000);
                                }
                            }
                        }

                        $(document).ready(function () {
                            toggleStentPlacementResonDiv();

                            $("#<%=StentCorrectPlacementRadioButton.ClientID%> input").click(function () {
                                toggleStentPlacementResonDiv()
                            });
                            togglePEGPlacementReasonDiv();
                            $("#<%=CorrectPEGPlacementRadioButtonList.ClientID%> input").click(function () {
                                togglePEGPlacementReasonDiv();
                            });

                           
                           

                        });

                        function BandLigationValueChanged(sender, eventArgs) {
                            if (eventArgs.get_newValue() < $("#<%=BandLigationSuccessfulRadNumericTextBox.ClientID%>").val()) {
                                $("#<%=BandLigationSuccessfulRadNumericTextBox.ClientID%>").val(eventArgs.get_newValue());
                            }
                        }

                        function BandLigationSuccessfulValueChanged(sender, eventArgs) {
                            if (eventArgs.get_newValue() > $("#<%=BandLigationPerformedRadNumericTextBox.ClientID%>").val()) {
                                $("#<%=BandLigationPerformedRadNumericTextBox.ClientID%>").val(eventArgs.get_newValue());
                            }
                        }

                        function ClipValueChanged(sender, eventArgs) {
                            if (eventArgs.get_newValue() < $("#<%=ClipSuccessfulRadNumericTextBox.ClientID%>").val()) {
                                $("#<%=ClipSuccessfulRadNumericTextBox.ClientID%>").val(eventArgs.get_newValue());
                            }
                            
                        }

                        function ClipSuccessValueChanged(sender, eventArgs) {
                            if (eventArgs.get_newValue() > $("#<%=ClipRadNumericTextBox.ClientID%>").val()) {
                                $("#<%=ClipRadNumericTextBox.ClientID%>").val(eventArgs.get_newValue());
                            }
                        }

                        function togglePEGPlacementReasonDiv() {
                            if ($("#<%=CorrectPEGPlacementRadioButtonList.ClientID%> input:checked").val() == "2") {
                                $("#<%=CorrectPlacementReasonSpan.ClientID%>").show();
                            }
                            else {
                                $("#<%=CorrectPlacementReasonSpan.ClientID%>").hide();
                            }

                        }

                        function toggleStentPlacementResonDiv() {
                            if ($("#<%=StentCorrectPlacementRadioButton.ClientID%> input:checked").val() == "0") {
                                $(".incorrect-placement-reason").show();
                            }
                            else {
                                $('.incorrect-placement-reason').hide();
                            }
                        }

                        /* not work this portion for issue --> 4214 */

                        $($find("#<%= RadWindow1.ClientID%>")).ready(function () {

                           $("#<%= OesoDilNilByMouthCheckBox.ClientID%>").click(function () {
                                if ($("#<%= OesoDilNilByMouthCheckBox.ClientID%>").is(':checked')) {
                      <%-- $("#<%= OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("<%= _OesoDilNilByMouthHrs%>");--%>
                                    $("#<%= OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("4");
                                } else {
                                    $("#<%= OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=OesoDilNilByMouthHrsRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();                             
                                if (i <= 0) {
                                    $("#<%= OesoDilNilByMouthCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= OesoDilNilByMouthCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                            $("#<%= OesoDilXRayCheckBox.ClientID%>").click(function () {
                                if ($("#<%= OesoDilXRayCheckBox.ClientID%>").is(':checked')) {
                       <%--$("#<%= OesoDilXRayHrsRadNumericTextBox.ClientID%>").val("<%= _OesoDilXRayHrs%>");--%>
                                    $("#<%= OesoDilXRayHrsRadNumericTextBox.ClientID%>").val("4");
                                } else {
                                    $("#<%= OesoDilXRayHrsRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= OesoDilXRayHrsRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=OesoDilXRayHrsRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= OesoDilXRayCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= OesoDilXRayCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                            $("#<%= OesoDilSoftDietCheckBox.ClientID%>").click(function () {
                                if ($("#<%= OesoDilSoftDietCheckBox.ClientID%>").is(':checked')) {
                       <%--$("#<%= OesoDilSoftDietDaysRadNumericTextBox.ClientID%>").val("<%= _OesoDilSoftDietDays%>");--%>
                                    $("#<%= OesoDilSoftDietDaysRadNumericTextBox.ClientID%>").val("4");
                                } else {
                                    $("#<%= OesoDilSoftDietDaysRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= OesoDilSoftDietDaysRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=OesoDilSoftDietDaysRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= OesoDilSoftDietCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= OesoDilSoftDietCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                            $("#<%= OesoDilWarmFluidsCheckBox.ClientID%>").click(function () {
                                if ($("#<%= OesoDilWarmFluidsCheckBox.ClientID%>").is(':checked')) {
                       <%--$("#<%= OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("<%= _OesoDilWarmFluidsHrs%>");--%>
                                    $("#<%= OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("4");
                                } else {
                                    $("#<%= OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=OesoDilWarmFluidsHrsRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= OesoDilWarmFluidsCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= OesoDilWarmFluidsCheckBox.ClientID%>").prop('checked', true);
                                }
                            });
                            ///////////////////////////////////////////////////////
                            $("#<%= YAGDilNilByMouthCheckBox.ClientID%>").click(function () {
                                if ($("#<%= YAGDilNilByMouthCheckBox.ClientID%>").is(':checked')) {
                //$("#<%= YAGDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("= YagDilNilByMouthHrs%>");
                                } else {
                                    $("#<%= YAGDilNilByMouthHrsRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= YAGDilNilByMouthHrsRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=YAGDilNilByMouthHrsRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= YAGDilNilByMouthCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= YAGDilNilByMouthCheckBox.ClientID%>").prop('checked', true);
                                }
                            });


                            $("#<%= YagDilSoftDietCheckBox.ClientID%>").click(function () {
                                if ($("#<%= YagDilSoftDietCheckBox.ClientID%>").is(':checked')) {
                //$("#<%= YagDilSoftDietDaysRadNumericTextBox.ClientID%>").val("= YagDilSoftDietDays%>");
                                } else {
                                    $("#<%= YagDilSoftDietDaysRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= YagDilSoftDietDaysRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=YagDilSoftDietDaysRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= YagDilSoftDietCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= YagDilSoftDietCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                            $("#<%= YagDilWarmFluidsCheckBox.ClientID%>").click(function () {
                                if ($("#<%= YagDilWarmFluidsCheckBox.ClientID%>").is(':checked')) {
                //$("#<%= YagDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("= YagDilWarmFluidsHrs%>");
                                } else {
                                    $("#<%= YagDilWarmFluidsHrsRadNumericTextBox.ClientID%>").val("0");
                                }
                            });

                            $("#<%= YagDilWarmFluidsHrsRadNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=YagDilWarmFluidsHrsRadNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= YagDilWarmFluidsCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= YagDilWarmFluidsCheckBox.ClientID%>").prop('checked', true);
                                }
                            });
                        });

                        /* not work this portion for issue --> 4214 */


                        $($find("#<%= RadWindow3.ClientID%>")).ready(function () {

                            $("#<%= NilByMouthCheckBox.ClientID%>").click(function () {
                                if ($("#<%= NilByMouthCheckBox.ClientID%>").is(':checked')) {
                //$("#<%= NilByMouthHrsNumericTextBox.ClientID%>").val("= NilByMouthHrs%>");
                                } else {
                                    $("#<%=NilByMouthHrsNumericTextBox.ClientID%>").val("0");
                                }
                            });
                            $("#<%= NilByMouthHrsNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=NilByMouthHrsNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= NilByMouthCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= NilByMouthCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                            $("#<%= NilByProcCheckBox.ClientID%>").click(function () {
                                if ($("#<%= NilByProcCheckBox.ClientID%>").is(':checked')) {
                //$("#<%= NilByProcHrsNumericTextBox.ClientID%>").val("= NilByProcHrs%>");
                                } else {
                                    $("#<%=NilByProcHrsNumericTextBox.ClientID%>").val("0");
                                }
                            });
                            $("#<%= NilByProcHrsNumericTextBox.ClientID%>").change(function (sender) {

                                var valueTbx = $find('<%=NilByProcHrsNumericTextBox.ClientID%>');
                                var i = valueTbx.get_value();
                                if (i <= 0) {
                                    $("#<%= NilByProcCheckBox.ClientID%>").prop('checked', false);
                                } else {
                                    $("#<%= NilByProcCheckBox.ClientID%>").prop('checked', true);
                                }
                            });

                        });

                    </script>

                    <!-- end of therapeutics -->

                </telerik:RadPane>
                <telerik:RadPane ID="ButtonsRadPane" runat="server" Width="670px" Height="85px" Scrolling="None" CssClass="TherapeuticDetailsButtonsPane" BorderStyle="None" BorderWidth="0px">
                    <div id="cmdOtherData">
                        <div class="shaded-tab-header" style="padding: 10px 0px 0 20px; width: 780px; margin-bottom: 10px; height: 32px;">
                            <label for="OtherTextBox" style="padding-right: 15px;">Other</label>
                            <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="680px" TabIndex="83" />
                        </div>

                        <div class="" style="width: 680px; display:none; margin-bottom: 10px; height: 32px; box-sizing: content-box">
                            <table style="width: 95%;">
                                <tr>
                                    <td style="text-align: right;">
                                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="saveButtonClicked" />
                                        <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </telerik:RadPane>
            </telerik:RadSplitter>
        </div>

        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>

<script type="text/javascript">

    $(window).on('load', function () {
        $('input[type="checkbox"]').each(function () {
            ToggleTRs($(this));
        });
        $('input[type="checkbox"]').on('click', function () {
            ToggleTRs($(this));
        });

    });

    $(document).ready(function () {
        $('#<%=chkNoneCheckBox.ClientID%>').on('click', function () {
            ToggleNoneCheckBox(true);
            $("#OtherTextBox").val("");
        })

        /* ########### Event: Radio Frequency Ablation Check => OnChange()      ########### */
        //$("[id$=RFACheckBox").on('change', function () {
        //    ShowRFADiv((this).name);
        //});

        //########### END of ALL CheckBox Events ################

        $('[id$=_EmrTypeRadioButtonList]').on('change', function (event) {
            var currentControl = event.target;
            //ShowEndoscopic(UserControlPrefix);
        });

        $('[id$=RFATypeRadioButtonList]').on('change', function (event) {
            var currentControl = event.target;
            //ShowRFADiv(UserControlPrefix);
        });

        $('#OtherTextBox').on('input', function () {
            if (!$('#<%=chkNoneCheckBox.ClientID %>').is(':checked')) { return; }
            if ($('#<% =OtherTextBox.ClientID %>').val() != '') {
                $('#<%=chkNoneCheckBox.ClientID %>').removeAttr("checked");
            }
        });
        $('#TherapeuticsTable tr td:first-child input[type=checkbox], input[type=radio]').change(function () {
            ToggleTRs($(this));
            $('#<%=chkNoneCheckBox.ClientID%>').prop("checked", false);
        });

    });

    function CloseWindow() {
        window.parent.CloseWindow();
    }

    function ToggleTRs(chkbox) {     
        if (chkbox[0].id == "ScopePassCheckBox") { return; }
        if (chkbox[0].id == "EmrCheckBox") {
            if (chkbox.is(':checked')) {
                if (!$('EmrTypeRadioButtonList_1').is(':checked'))
                    !$('EmrTypeRadioButtonList_0').prop('checked', true);
            }
            else {
                $("EmrTypeRadioButtonList_0").attr('checked', false);
                $("EmrTypeRadioButtonList_1").attr('checked', false);
            }
        }
        if (chkbox[0].id != ("chkNoneCheckBox")) {
            var checked = chkbox.is(':checked');
            if (checked) {
                $("NoneCheckBox").attr('checked', false);
            }
            chkbox.closest('td')
                .nextUntil('tr').each(function () {
                    if (checked) {
                        $(this).show();
                        $(this).css("visibility", "visible");
                    }
                    else {
                        $(this).hide();
                        $(this).css("visibility", "hidden");
                        ClearControls($(this));
                    }
                });
            var subRows = chkbox.closest('td').closest('tr').attr('hasChildRows');
            if (typeof subRows !== typeof undefined && subRows == "1") {
                chkbox.closest('tr').nextUntil('tr [headRow="1"]').each(function () {
                    if (checked) {
                        $(this).show();
                        $(this).css("visibility", "visible");
                    }
                    else {
                        $(this).hide();
                        $(this).css("visibility", "hidden");
                        ClearControls($(this));
                    }
                });
            }
        }
    }

    function ToggleNoneCheckBox(checked) {
        if (checked) {
            $("#TherapeuticsTable tr td:first-child").each(function () {
                $(this).find("input:checkbox:checked, input:radio:checked").prop('checked', false);
                $(this).find("input:text").val("");
                ToggleTRs($(this));
            });
        }
    }
    function ClearControls(tableCell) {
        tableCell.find("input:radio:checked").removeAttr("checked");
        tableCell.find("input:checkbox:checked").removeAttr("checked");
        tableCell.find("input:text").val("");
        if ($("chkNoneCheckBox").is(':checked')) {
            $("OtherTextBox").val("");
        }
    }

    function ShowEndoscopic(ThisUserControlPrefix) {
        if ($('EmrTypeRadioButtonList_0').is(':checked') || ($('EmrTypeRadioButtonList_1').is(':checked'))) {
            if (!$("EmrCheckBox").is(':checked')) {
                $("EmrCheckBox").prop('checked', true);
                ToggleTRs($("EmrCheckBox"));
            }
        }
    }

    function ShowRFADiv(currentUC_Name) {
        if ($('RFATypeRadioButtonList_0').is(':checked')) {
            $("RFADiv").show();
            $('.RFANumSegTreatedSpan').html('No. of 3cm segments treated');
            $find('.segment-treated-qty').set_maxValue(999);

            $('.RFANumTimesSegTreatedSpan').html('No. of times each segment treated (1-2)');
            $find('.segment-treated-times').set_maxValue(2);

        } else if ($('RFATypeRadioButtonList_1').is(':checked')) {
            $("RFADiv").show();

            $('.RFANumSegTreatedSpan').html('No. of segments treated (1 to 40)');
            $find('.segment-treated-qty').set_maxValue(40);

            $('.RFANumTimesSegTreatedSpan').html('No. of times each segment treated (1-4)');
            $find('.segment-treated-times').set_maxValue(4);
        } else {
            $("RFADiv").hide();
        }

    }

    function toggleArgonBeamRequired() {
        if ($('#<%=ArgonBeamDiathermyCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=ArgonBeamDiathermyPulsesNumericTextBox.ClientID%>', 'pulses');
        }
        else {
            removeRequiredField('<%=ArgonBeamDiathermyPulsesNumericTextBox.ClientID%>', 'pulses');
        }
    }

    function toggleBandLigationRequired() {
        if ($('#<%=BandLigationCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=BandLigationPerformedRadNumericTextBox.ClientID%>', 'band ligation qty performed');
            setRequiredField('<%=BandLigationSuccessfulRadNumericTextBox.ClientID%>', 'band ligation qty sucessful');
        }
        else {
            removeRequiredField('<%=BandLigationPerformedRadNumericTextBox.ClientID%>', 'band ligation qty performed');
            removeRequiredField('<%=BandLigationSuccessfulRadNumericTextBox.ClientID%>', 'band ligation qty sucessful');
        }
    }

    function toggleEndoscopicRequired() {
        if ($('#<%=EmrCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=EmrTypeRadioButtonList.ClientID%>', 'endoscopic removal type');
        }
        else {
            removeRequiredField('<%=EmrTypeRadioButtonList.ClientID%>', 'endoscopic removal type');
        }
    }

    function toggleFNBRequired() {
        if ($('#<%=FineNeedleBiopsyCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=FineNeedleBiopsyPerformedRadNumericTextBox.ClientID%>', 'FNB performed total');
            setRequiredField('<%=FineNeedleBiopsyRetreivedRadNumericTextBox.ClientID%>', 'FNB retrieved total');
            setRequiredField('<%=FineNeedleBiopsySuccessfulRadNumericTextBox.ClientID%>', 'FNB successful total');
        }
        else {
            removeRequiredField('<%=FineNeedleBiopsyPerformedRadNumericTextBox.ClientID%>', 'FNB performed total');
            removeRequiredField('<%=FineNeedleBiopsyRetreivedRadNumericTextBox.ClientID%>', 'FNB retrieved total');
            removeRequiredField('<%=FineNeedleBiopsySuccessfulRadNumericTextBox.ClientID%>', 'FNB successful total');
        }
    }

    function toggleFNARequired() {
        if ($('#<%=FineNeedleAspirationCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=FineNeedleTypeRadioButtonList.ClientID%>', 'FNA type');
            setRequiredField('<%=FineNeedleAspirationPerformedRadNumericTextBox.ClientID%>', 'FNA performed total');
            setRequiredField('<%=FineNeedleAspirationRetreivedRadNumericTextBox.ClientID%>', 'FNA retrieved total');
            setRequiredField('<%=FineNeedleAspirationSuccessfulRadNumericTextBox.ClientID%>', 'FNA successful total');
        }
        else {
            removeRequiredField('<%=FineNeedleTypeRadioButtonList.ClientID%>', 'FNA type');
            removeRequiredField('<%=FineNeedleAspirationPerformedRadNumericTextBox.ClientID%>', 'FNA performed total');
            removeRequiredField('<%=FineNeedleAspirationRetreivedRadNumericTextBox.ClientID%>', 'FNA retrieved total');
            removeRequiredField('<%=FineNeedleAspirationSuccessfulRadNumericTextBox.ClientID%>', 'FNA successful total');
        }
    }

    function toggleInjectionTherapyRequired() {
        if ($('#<%=InjectionTherapyCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=InjectionVolumeNumericTextBox.ClientID%>', 'injection total');
        }
        else {
            removeRequiredField('<%=InjectionVolumeNumericTextBox.ClientID%>', 'injection total');
        }
    }

    function toggleMarkingRequired() {
        if ($('#<%=MarkingCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=MarkingTypeComboBox.ClientID%>', 'marking type');
            setRequiredField('<%=MarkedQtyNumericTextBox.ClientID%>', 'marking total');
        }
        else {
            removeRequiredField('<%=MarkingTypeComboBox.ClientID%>', 'marking type');
            removeRequiredField('<%=MarkedQtyNumericTextBox.ClientID%>', 'marking total');
        }
    }

    function toggleStentInsertionRequired() {
        if ($('#<%=StentInsertionCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=StentInsertionQtyNumericTextBox.ClientID%>', 'stent insertion total');
        }
        else {
            removeRequiredField('<%=StentInsertionQtyNumericTextBox.ClientID%>', 'stent insertion total');
        }
    }
    /* changed by mostafiz */

    function toggleBalloonDilationRequired() {
        if ($('#<%=BalloonDilationCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=BalloonDilationDiaNumericTextBox.ClientID%>', 'balloon dilation total');
    }
    else {
            removeRequiredField('<%=BalloonDilationDiaNumericTextBox.ClientID%>', 'balloon dilation total');
        }
    }
    /* changed by mostafiz */

    function toggleVaricealSclerotherapyRequired() {
        if ($('#<%=VaricealSclerotherapyCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=VaricealScleroInjNumNumericTextBox.ClientID%>', 'variceal sclerotherapy injection total');
        }
        else {
            removeRequiredField('<%=VaricealScleroInjNumNumericTextBox.ClientID%>', 'variceal sclerotherapy injection total');
        }
    }

    function toggleBandingRequired() {
        if ($('#<%=BandingPilesCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=BandingNumRadNumericTextBox.ClientID%>', 'banding total');
        }
        else {
            removeRequiredField('<%=BandingNumRadNumericTextBox.ClientID%>', 'banding total');
        }
    }

    function toggleCoilRequired() {
        if ($('#<%=chkCoil.ClientID%>').is(':checked')) {
            setRequiredField('<%=CoilQty.ClientID%>', 'coil total');
        }
        else {
            removeRequiredField('<%=CoilQty.ClientID%>', 'coil total');
        }
    }

    function toggleClipRequired() {
        if ($('#<%=ClipCheckBox.ClientID%>').is(':checked')) {
            setRequiredField('<%=ClipRadNumericTextBox.ClientID%>', 'clip performed total');
            setRequiredField('<%=ClipSuccessfulRadNumericTextBox.ClientID%>', 'clip successful total');
        }
        else {
            removeRequiredField('<%=ClipRadNumericTextBox.ClientID%>', 'clip performed total');
            removeRequiredField('<%=ClipSuccessfulRadNumericTextBox.ClientID%>', 'clip successful total');
        }
    }

    function handleValueChange(currentVal, limitElem, reverse = false) {

        if (!reverse && limitElem.val() < currentVal) {
            limitElem.val(currentVal);
        } else if (reverse && limitElem.val() > currentVal) {
            limitElem.val(currentVal);
        }
    }

    function FNA_FNBValueChanged(sender, args) {
        var isFNA = sender.get_id().indexOf('FineNeedleAspiration') > -1 ? true : false;
        var currentVal = sender.get_value();

        var performed = isFNA ? $('#<%=FineNeedleAspirationPerformedRadNumericTextBox.ClientID%>') : $('#<%=FineNeedleBiopsyPerformedRadNumericTextBox.ClientID%>');
        var retrieved = isFNA ? $('#<%=FineNeedleAspirationRetreivedRadNumericTextBox.ClientID%>') : $('#<%=FineNeedleBiopsyRetreivedRadNumericTextBox.ClientID%>');
        var successful = isFNA ? $('#<%=FineNeedleAspirationSuccessfulRadNumericTextBox.ClientID%>') : $('#<%=FineNeedleBiopsySuccessfulRadNumericTextBox.ClientID%>');


        if (sender.get_id().includes(isFNA ? 'FineNeedleAspirationPerformedRadNumericTextBox' : 'FineNeedleBiopsyPerformedRadNumericTextBox')) {
            if (currentVal < retrieved.val()) {
                setTimeout(function () {
                    retrieved.val(currentVal);
                    successful.val(currentVal);
                }, 1);
            }
        }
        else if (sender.get_id().includes(isFNA ? 'FineNeedleAspirationRetreivedRadNumericTextBox' : 'FineNeedleBiopsyRetreivedRadNumericTextBox')) {
            setTimeout(function () {
                handleValueChange(currentVal, performed);
                handleValueChange(currentVal, successful, true);
            }, 1);
        }
        else if (sender.get_id().includes(isFNA ? 'FineNeedleAspirationSuccessfulRadNumericTextBox' : 'FineNeedleBiopsySuccessfulRadNumericTextBox')) {
            setTimeout(function () {
                handleValueChange(currentVal, retrieved);
                handleValueChange(currentVal, performed);
            }, 1);
        }
    }

</script>

</html>

