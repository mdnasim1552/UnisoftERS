<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_Visualisation" CodeBehind="Visualisation.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="VHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <%--<script type="text/javascript" src="../../Scripts/global.js"></script>--%>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <style type="text/css">
        .mainPageContainer {
            width: 850px;
            margin-left: 1em;
        }
    </style>

    <script type="text/javascript">
        function GetThisPrefix(controlName) {
            return controlName.indexOf("_ER") > 0 ? "#BodyContentPlaceHolder_pBodyContentPlaceHolder_ER_" : "#BodyContentPlaceHolder_pBodyContentPlaceHolder_";
        }

        window.onbeforeunload = function (event) {
            document.getElementById("<%= SaveOnly.ClientID %>").click();
        }

        $(document).ready(function () {
            SetAccessViaOther();
            $("[id$=AccessViaDiv] input:radio").click(function () {
                SetAccessViaOther();
            });
            $("#<%= ControlsRadPane.ClientID%>").width(850);

            if ('<%=trainEE_Exist%>' == 'True') {
                //console.log("TrainEE exist: < %=trainEE_Exist%>");
            } else {
                //  $('[id$=radTabStripVisualisation]').hide(); //### Hide the Div header Tab.. Not required to show when ONLY ER is present!
            }

            $("[id$=Majortable] input:radio").click(function (sender) {
                var ucPrefix = GetThisPrefix($(this).attr("id"));
                var v = $(this).val(); var c = $(this).is(':checked');
                //console.log("$(this).attr(id) : " + $(this).attr("id"));
                //console.log("Majortable input:radio=> Prefix: " + ucPrefix);
                //console.log("C =>" + c + ", v=> " + v);

                if (c == true) {
                    if (v.startsWith("optBile")) {
                        $(ucPrefix + "BileReasonsDiv1").hide();
                        $(ucPrefix + "BileReasonsDiv2").hide();
                        $(ucPrefix + "BileReasonsDiv4").hide();
                    } else if (v.startsWith("optPan")) {
                        $(ucPrefix + "PancreaticReasonsDiv1").hide();
                        $(ucPrefix + "PancreaticReasonsDiv2").hide();
                        $(ucPrefix + "PancreaticReasonsDiv4").hide();
                    }

                    if (v.indexOf('optBile1') >= 0) {
                        $(ucPrefix + "BileReasonsDiv1").show();
                    } else if (v.indexOf('optBile2') >= 0) {
                        $(ucPrefix + "BileReasonsDiv2").show();
                    } else if (v == 'optBile3') {
                    } else if (v.indexOf('optBile4') >= 0) {
                        $(ucPrefix + "BileReasonsDiv4").show();
                    } else if (v.indexOf('optPan1') >= 0) {
                        $(ucPrefix + "PancreaticReasonsDiv1").show();
                    } else if (v.indexOf('optPan2') >= 0) {
                        $(ucPrefix + "PancreaticReasonsDiv2").show();
                    } else if (v == 'optPan3') {
                    } else if (v.indexOf('optPan4') >= 0) {
                        $(ucPrefix + "PancreaticReasonsDiv4").show();
                    }
                }

            });

            $("[id$=Minortable] input:radio").click(function (sender) {
                var v = $(this).val(); var c = $(this).is(':checked');
                var ucPrefix = GetThisPrefix($(this).attr("id"));

                //console.log("minortable input:radio=> Prefix: " + ucPrefix);
                //console.log("C =>" + c + ", v=> " + v);

                if (c == true) {
                    $(ucPrefix + "MinorPapReasonsDiv1").hide();
                    $(ucPrefix + "MinorPapReasonsDiv2").hide();
                    $(ucPrefix + "MinorPapReasonsDiv4").hide();
                    if (v.indexOf('optMinorPap1') >= 0) {
                        $(ucPrefix + "MinorPapReasonsDiv1").show();
                    } else if (v.indexOf('optMinorPap2') >= 0) {
                        $(ucPrefix + "MinorPapReasonsDiv2").show();
                    } else if (v.indexOf('optMinorPap3') >= 0) {
                    } else if (v.indexOf('optMinorPap4') >= 0) {
                        $(ucPrefix + "MinorPapReasonsDiv4").show();
                    }
                }
            });


            $("[id^=hepatobiliarytable] input:checkbox").click(function (sender) {
                var v = $(this).attr("id");
                var ucPrefix = GetThisPrefix($(this).attr("id"));

                if ($(this).is(':checked')) {
                    if (v.endsWith("chkHVNotVisualised")) {
                        $(ucPrefix + "chkHVWholeBiliary").prop('checked', false);
                        SetCheckBoxChecked(ucPrefix + 'chkExcept', 5, true); //## Check chkExcept1 to 5
                        $(ucPrefix + "limitedtable").show();
                        $(ucPrefix + "limitedtable input:radio").prop('checked', false);
                        $(ucPrefix + "AcinarTR").hide();
                    } else if (v.endsWith("chkHVWholeBiliary")) {
                        $(ucPrefix + "chkHVNotVisualised").prop('checked', false);
                        $(ucPrefix + "limitedtable").hide();
                        $(ucPrefix + "limitedtable input:radio").prop('checked', false);
                        $(ucPrefix + "AcinarTR").show();

                    } else if (v.endsWith("chkExcept1") || v.endsWith("chkExcept2") || v.endsWith("chkExcept3") || v.endsWith("chkExcept4") || v.endsWith("chkExcept5")) {
                        $(ucPrefix + "chkHVNotVisualised").prop('checked', false);
                        $(ucPrefix + "chkHVWholeBiliary").prop('checked', true);
                        $(ucPrefix + "limitedtable").show();
                        $(ucPrefix + "AcinarTR").show();

                    }
                } else {
                    if (v.endsWith("chkHVWholeBiliary")) {
                        SetCheckBoxChecked(ucPrefix + 'chkExcept', 5, false); //## UNCheck chkExcept1 to 5
                        $(ucPrefix + "limitedtable").hide();
                        $(ucPrefix + "limitedtable input:radio").prop('checked', false);
                        $(ucPrefix + "AcinarTR input:checkbox").prop('checked', false);
                    }
                }
            });


            $("[id^=pancreatictable] input:checkbox").click(function (sender) {
                var v = $(this).attr("id");
                //var c = $(this).is(':checked');
                var ucPrefix = GetThisPrefix($(this).attr("id"));

                if ($(this).is(':checked')) {
                    if (v.endsWith("pNotVisualisedCheckBox")) {
                        $(ucPrefix + "WholeCheckBox").prop('checked', false);
                        SetCheckBoxChecked(ucPrefix + 'ExceptCheckBox', 7, true); //## Check ExceptCheckBox1 to 7
                        $(ucPrefix + "limitedtable1").show();
                        $(ucPrefix + "limitedtable1 input:radio").prop('checked', false);
                        $(ucPrefix + "chkAcinar2TR").hide();
                    } else if (v.endsWith("WholeCheckBox")) {
                        $(ucPrefix + "pNotVisualisedCheckBox").prop('checked', false);
                        $(ucPrefix + "PancreasCheckBox").prop('checked', false);
                        $(ucPrefix + "limitedtable1").hide();
                        $(ucPrefix + "limitedtable1 input:radio").prop('checked', false);
                        $(ucPrefix + "chkAcinar2TR").show();
                    } else if (v.endsWith('PancreasCheckBox')) {
                        $(ucPrefix + "WholeCheckBox").prop('checked', false);
                        $(ucPrefix + "pNotVisualisedCheckBox").prop('checked', false);
                    } else if (v.endsWith("ExceptCheckBox1") || v.endsWith("ExceptCheckBox2") || v.endsWith("ExceptCheckBox3") || v.endsWith("ExceptCheckBox4") || v.endsWith("ExceptCheckBox5") || v.endsWith("ExceptCheckBox6") || v.endsWith("ExceptCheckBox7")) {
                        $(ucPrefix + "pNotVisualisedCheckBox").prop('checked', false);
                        $(ucPrefix + "WholeCheckBox").prop('checked', true);
                        $(ucPrefix + "limitedtable1").show();
                        $(ucPrefix + "chkAcinar2TR").show();
                    }


                } else {
                    if (v.endsWith("WholeCheckBox") || (v.endsWith('PancreasCheckBox'))) {
                        $(ucPrefix + "chkExcept1").prop('checked', false);
                        SetCheckBoxChecked(ucPrefix + 'ExceptCheckBox', 7, false); //## Uncheck ExceptCheckBox1 to 7
                        $(ucPrefix + "limitedtable1").hide();
                        $(ucPrefix + "limitedtable1 input:radio").prop('checked', false);
                        $(ucPrefix + "chkAcinar2TR input:checkbox").prop('checked', false);

                    }
                }
            });

            $('#DuodenumTable input[type=checkbox]').change(function () {
                if (this.id.indexOf("Duodenum2ndPartNotEnteredCheckBox") >= 0 || this.id.indexOf("DuodenumNormalCheckBox") >= 0 || this.id.indexOf("DuodenumNotEnteredCheckBox") >= 0) {
                    $('#DuodenumTable input[type=checkbox]').not("[id*='" + this.id + "']").prop('checked', false);
                }
            });
        });

        function SetAccessViaOther() {
            if ($("#<%= optVA2.ClientID%>").is(':checked')) {
                $("#<%= cboAccessViaOther.ClientID%>").show();
            } else {
                $("#<%= cboAccessViaOther.ClientID%>").hide();
                //$find('<%= cboAccessViaOther.ClientID%>').clearSelection();
            }
        }

        ///### This will Check/Uncheck some Group of controls - based on Conditions
        function SetCheckBoxChecked(controlName, numberOfControls, isChecked) {
            for (var i = 1; i <= numberOfControls; i++) {
                $(controlName + i).prop('checked', (isChecked == 'true' ? true : false));
            }
        }

        function isoptLB2(sender) {
            var thisId = '#' + $(sender).attr('id');
            var optLB2Div = GetThisPrefix($(sender).attr('id')) + 'optLB2Div'; //## This is our Target div to Hide-> [Option Limited By]
            if (thisId.indexOf("optLB2") >= 0) {
                $(optLB2Div).show();
            } else {
                $(optLB2Div).hide();
            }
        }

        function isoptLB0(sender) {
            var thisId = $(sender).attr('id');
            var optOtherDiv = GetThisPrefix($(sender).attr('id')) + 'optOtherDiv';  //## This is our Target div to Hide-> [Option Limited By-> Other]
            if (thisId.indexOf("optOtherButton") >= 0) {
                $(optOtherDiv).show();
            } else {
                $(optOtherDiv).hide();
            }
        }

        function validateControls(sender, args) {
            var isValid = true;
           <%-- isValid = (
                (('<%=trainEE_Exist.ToString()%>' == 'True') && ($('.optBileDuct input:radio:checked').length > 0 || $('.optPanDuct input:radio:checked').length > 0 || $('.optMinorPapilla input:radio:checked').length > 0 || $('#<%=AbandonedCheckBox.ClientID%>').is(':checked'))) ||
                (('<%=trainEE_Exist.ToString()%>' == 'False') && ($('.optBileDuct_ER input:radio:checked').length > 0 || $('.optPanDuct_ER input:radio:checked').length > 0 || $('.optMinorPapilla_ER input:radio:checked').length > 0 || $('#<%=Abandoned_ER_CheckBox.ClientID%>').is(':checked')))
            )
               

            if (!isValid) {
                args.set_cancel(true);
                $find("<%=ValidationNotification.ClientID%>").show();
                $('#<%=ValidationErrorLabel.ClientID%>').text("You must select a Cannulation result or state whether the procedure was abandoned.");
            }--%>
        }
    </script>
</asp:Content>

<asp:Content ID="VBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" />

    <telerik:RadFormDecorator ID="decorateContentDiv" runat="server" DecoratedControls="All" DecorationZoneID="divVisualisation" Skin="Web20" />
    <div style="width: 850px;">
        <%--    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="900px" Orientation="Horizontal"  BorderSize="1" PanesBorderSize="1" Skin="Windows7" CssClass="mainPageContainer">--%>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">

            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="500px">
                <%--width is set to 850px in jQuery Document Ready--%>

                <div class="otherDataHeading">
                    <b>Visualisation</b>
                </div>
                <div id="divVisualisation" style="margin: 0px 20px;">
                    <fieldset style="padding: 0; margin-bottom: 10px; margin-left: 0px; width: 820px;">
                        <div id="AccessViaDiv" style="padding: 10px;">
                            <strong>Access via:</strong>
                            <span style="padding-left: 20px;" />
                            <asp:RadioButton ID="optAV1" runat="server" Text="pylorus" GroupName="optAccessVia" />
                            <span style="padding-left: 20px;" />
                            <asp:RadioButton ID="optVA2" runat="server" Text="other" GroupName="optAccessVia" />
                            <telerik:RadComboBox ID="cboAccessViaOther" runat="server" Skin="Office2007" />
                        </div>
                    </fieldset>
                    <br />
                    <fieldset style="padding: 0; margin-bottom: 10px; margin-left: 0px; width: 820px;">
                        <div id="DuodenumTable" style="padding: 10px;">
                            <strong>Duodenum:</strong>
                            <!--<span style="padding-left: 20px;" />-->
                            <asp:CheckBox ID="DuodenumNormalCheckBox" runat="server" Text="Normal" Visible="false" />
                            <span style="padding-left: 20px;" />
                            <asp:CheckBox ID="DuodenumNotEnteredCheckBox" runat="server" Text="Not Entered" />
                            <span style="padding-left: 20px;" />
                            <asp:CheckBox ID="Duodenum2ndPartNotEnteredCheckBox" runat="server" Text="2nd Part Not Entered" />
                             <span style="padding-left: 20px;" />
                            <asp:CheckBox ID="AmupllaNotEnteredCheckBox" runat="server" Text="Ampulla Not Visualised" />
                        </div>
                    </fieldset>

                    <div id="TabPageHolderDiv" style="padding: 0; float: left;">
                        <telerik:RadTabStrip ID="radTabStripVisualisation" runat="server" MultiPageID="radMultiVisPageViews" ReorderTabsOnSelect="True" RenderMode="Lightweight" Skin="Metro"  SelectedIndex="0">
                            <Tabs>
                                <telerik:RadTab PageViewID="TrainEEPageView" Text="EE" Font-Bold="true" Value="0" Selected="True" SelectedIndex="0" Visible="false" />
                                <%--TrainEE--%>
                                <telerik:RadTab PageViewID="TrainERPageView" Text="ER" Font-Bold="true" Value="1" Visible="false" />
                                <%--TrainER--%>
                                <telerik:RadTab PageViewID="ExtentPageView" Text="Extent & Contrast" Font-Bold="true" Value="2" Visible="false" />
                                <%--For both EE and ER--%>
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="radMultiVisPageViews" runat="server" Style="margin-bottom: 1em;" ScrollBars="None">
                            <telerik:RadPageView ID="TrainEEPageView" runat="server">
                                <div id="pageTrainEE" class="multiPageDivTab">
                                    <%--<unisoft:Visualisation runat="server" ID="VisualisationTrainEE" />--%>

                                    <table id="CannulationTable" runat="server" cellspacing="5" cellpadding="0" border="0">
                                        <tr style="vertical-align: top;">
                                            <td runat="server" id="IntendedDuctTD" style="width: 475px;">
                                                <fieldset style="width: 430px;">
                                                    <legend><b>Intended duct for cannulation</b></legend>
                                                    <table cellpadding="1" cellspacing="1" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="IntendedBileDuctCheckBox" runat="server" Text="bile duct" CssClass="jag-audit-control" />
                                                                <asp:CheckBox ID="IntendedPancreaticDuctCheckBox" runat="server" Text="pancreatic duct" Style="padding-left: 50px;" CssClass="jag-audit-control" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td runat="server" id="AbandonedTD" colspan="1">
                                                <fieldset>
                                                    <legend><b>Procedure</b></legend>
                                                    <table cellpadding="1" cellspacing="1" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="AbandonedCheckBox" runat="server" Text="Procedure abandoned" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>

                                        </tr>
                                        <tr style="vertical-align: top;">
                                            <td style="width: 475px;">
                                                <fieldset style="margin: 0px 5px; width: 430px;">
                                                    <legend><b>Cannulation via major papilla</b></legend>
                                                    <table id="Majortable" runat="server" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td class="jag-audit-control" style="width: 50%"><b>to bile duct was..</b></td>
                                                            <td class="jag-audit-control"><b>to pancreatic duct was..</b></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile1" runat="server" Text="successful" CssClass="optBileDuct jag-audit-control" GroupName="optBileDuct" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan1" runat="server" Text="successful" CssClass="optPanDuct jag-audit-control" GroupName="optPanDuct" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile2" runat="server" Text="partially successful" CssClass="optBileDuct jag-audit-control" GroupName="optBileDuct" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan2" runat="server" Text="partially successful" CssClass="optPanDuct jag-audit-control" GroupName="optPanDuct" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile3" runat="server" Text="not attempted" CssClass="optBileDuct jag-audit-control" GroupName="optBileDuct" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan3" runat="server" Text="not attempted" CssClass="optPanDuct jag-audit-control" GroupName="optPanDuct" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile4" runat="server" Text="unsuccessful due to" CssClass="optBileDuct jag-audit-control" GroupName="optBileDuct" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan4" runat="server" Text="unsuccessful due to" CssClass="optPanDuct jag-audit-control" GroupName="optPanDuct" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="height: 4px;"></td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div id="BileReasonsDiv1" runat="server" style="display: none; padding-right: 5px">
                                                                    <label>Using</label>
                                                                    <telerik:RadComboBox ID="cboBileReasons1" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="BileReasonsDiv2" runat="server" style="display: none; padding-right: 5px">
                                                                    <label>(reason)</label>
                                                                    <telerik:RadComboBox ID="cboBileReasons2" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="BileReasonsDiv4" runat="server" style="display: none; padding-right: 5px">
                                                                    <telerik:RadComboBox ID="cboBileReasons4" runat="server" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div id="PancreaticReasonsDiv1" runat="server" style="display: none">
                                                                    <label>Using</label>
                                                                    <telerik:RadComboBox ID="cboPancreaticReasons1" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="PancreaticReasonsDiv2" runat="server" style="display: none">
                                                                    <label>(reason)</label>
                                                                    <telerik:RadComboBox ID="cboPancreaticReasons2" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="PancreaticReasonsDiv4" runat="server" style="display: none">
                                                                    <telerik:RadComboBox ID="cboPancreaticReasons4" runat="server" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 280px">
                                                    <legend><b>Cannulation via minor papilla</b></legend>
                                                    <table id="Minortable" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap1" runat="server" Text="successful" CssClass="optMinorPapilla jag-audit-control" GroupName="optMinorPapilla" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap2" runat="server" Text="partially successful" CssClass="optMinorPapilla jag-audit-control" GroupName="optMinorPapilla" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap3" runat="server" Text="not attempted" CssClass="optMinorPapilla jag-audit-control" GroupName="optMinorPapilla" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap4" runat="server" Text="unsuccessful due to" CssClass="optMinorPapilla jag-audit-control" GroupName="optMinorPapilla" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div id="MinorPapReasonsDiv1" runat="server" style="display: none">
                                                                    <label>Using</label>
                                                                    <telerik:RadComboBox ID="cboMinorPapReasons1" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="MinorPapReasonsDiv2" runat="server" style="display: none">
                                                                    <label>(reason)</label>
                                                                    <telerik:RadComboBox ID="cboMinorPapReasons2" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="MinorPapReasonsDiv4" runat="server" style="display: none">
                                                                    <telerik:RadComboBox ID="cboMinorPapReasons4" runat="server" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="TrainERPageView" runat="server">
                                <div id="pageTrainER" class="multiPageDivTab">
                                    <%--<unisoft:Visualisation runat="server" ID="VisualisationTrainER" />--%>

                                    <table id="ER_CannulationTable" runat="server" cellspacing="5" cellpadding="0" border="0">
                                        <tr style="vertical-align: top;">
                                            <td runat="server" id="IntendedDuct_ER_TD" style="width: 475px;">
                                                <fieldset style="width: 430px;">
                                                    <legend><b>Intended duct for cannulation</b></legend>
                                                    <table cellpadding="1" cellspacing="1" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="IntendedBileDuct_ER_CheckBox" runat="server" Text="bile duct" CssClass="jag-audit-control" />
                                                                <asp:CheckBox ID="IntendedPancreaticDuct_ER_CheckBox" runat="server" Text="pancreatic duct" Style="padding-left: 50px;" CssClass="jag-audit-control" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td runat="server" id="Abandoned_ER_TD" colspan="1">
                                                <fieldset>
                                                    <legend><b>Procedure</b></legend>
                                                    <table cellpadding="1" cellspacing="1" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="Abandoned_ER_CheckBox" runat="server" Text="Procedure abandoned" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr style="vertical-align: top;">
                                            <td style="width: 475px;">
                                                <fieldset style="margin: 0px 5px; width: 430px;">
                                                    <legend><b>Cannulation via major papilla</b></legend>
                                                    <table id="ER_Majortable" runat="server" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td class="jag-audit-control" style="width: 50%"><b>to bile duct was..</b></td>
                                                            <td class="jag-audit-control"><b>to pancreatic duct was..</b></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile1_ER" runat="server" Text="successful" CssClass="optBileDuct_ER jag-audit-control" GroupName="optBileDuct_ER" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan1_ER" runat="server" Text="successful" CssClass="optPanDuct_ER jag-audit-control" GroupName="optPanDuct_ER" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile2_ER" runat="server" Text="partially successful" CssClass="optBileDuct_ER jag-audit-control" GroupName="optBileDuct_ER" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan2_ER" runat="server" Text="partially successful" CssClass="optPanDuct_ER jag-audit-control" GroupName="optPanDuct_ER" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile3_ER" runat="server" Text="not attempted" CssClass="optBileDuct_ER jag-audit-control" GroupName="optBileDuct_ER" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan3_ER" runat="server" Text="not attempted" CssClass="optPanDuct_ER jag-audit-control" GroupName="optPanDuct_ER" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optBile4_ER" runat="server" Text="unsuccessful due to" CssClass="optBileDuct_ER jag-audit-control" GroupName="optBileDuct_ER" /></td>
                                                            <td>&nbsp;<asp:RadioButton ID="optPan4_ER" runat="server" Text="unsuccessful due to" CssClass="optPanDuct_ER jag-audit-control" GroupName="optPanDuct_ER" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="height: 4px;"></td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div id="ER_BileReasonsDiv1" runat="server" style="display: none; padding-right: 5px">
                                                                    <label>Using</label>
                                                                    <telerik:RadComboBox ID="cboBileReasons1_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="ER_BileReasonsDiv2" runat="server" style="display: none; padding-right: 5px">
                                                                    <label>(reason)</label>
                                                                    <telerik:RadComboBox ID="cboBileReasons2_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="ER_BileReasonsDiv4" runat="server" style="display: none; padding-right: 5px">
                                                                    <telerik:RadComboBox ID="cboBileReasons4_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div id="ER_PancreaticReasonsDiv1" runat="server" style="display: none">
                                                                    <label>Using</label>
                                                                    <telerik:RadComboBox ID="cboPancreaticReasons1_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="ER_PancreaticReasonsDiv2" runat="server" style="display: none">
                                                                    <label>(reason)</label>
                                                                    <telerik:RadComboBox ID="cboPancreaticReasons2_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="ER_PancreaticReasonsDiv4" runat="server" style="display: none">
                                                                    <telerik:RadComboBox ID="cboPancreaticReasons4_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 280px">
                                                    <legend><b>Cannulation via minor papilla</b></legend>
                                                    <table id="ER_Minortable" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap1_ER" runat="server" Text="successful" GroupName="optMinorPapilla_ER" CssClass="jag-audit-control" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap2_ER" runat="server" Text="partially successful" GroupName="optMinorPapilla_ER" CssClass="jag-audit-control" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap3_ER" runat="server" Text="not attempted" GroupName="optMinorPapilla_ER" CssClass="jag-audit-control" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;<asp:RadioButton ID="optMinorPap4_ER" runat="server" Text="unsuccessful due to" GroupName="optMinorPapilla_ER" CssClass="jag-audit-control" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div id="ER_MinorPapReasonsDiv1" runat="server" style="display: none">
                                                                    <label>Using</label>
                                                                    <telerik:RadComboBox ID="cboMinorPapReasons1_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="ER_MinorPapReasonsDiv2" runat="server" style="display: none">
                                                                    <label>(reason)</label>
                                                                    <telerik:RadComboBox ID="cboMinorPapReasons2_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                                <div id="ER_MinorPapReasonsDiv4" runat="server" style="display: none">
                                                                    <telerik:RadComboBox ID="cboMinorPapReasons4_ER" runat="server" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="ExtentPageView" runat="server">
                                <div id="pageExtent" class="multiPageDivTab" style="overflow: auto; margin-left: 0;">
                                    <div id="ExtentDiv">
                                        <table id="tableMiddle" runat="server" cellspacing="5" cellpadding="0" border="0">
                                            <tr style="vertical-align: top;">
                                                <td style="width: 400px;">
                                                    <fieldset style="width: 385px;">
                                                        <legend><b>Extent of hepatobiliary visualisation</b></legend>
                                                        <table id="hepatobiliarytable" cellspacing="0" cellpadding="0" border="0">
                                                            <tr>
                                                                <td>&nbsp;<asp:CheckBox ID="chkHVNotVisualised" runat="server" Text="Not visualised" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;<asp:CheckBox ID="chkHVWholeBiliary" runat="server" Text="Whole biliary system visualised" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table id="tableMidSub1" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                                        <tr>
                                                                            <td style="width: 23px;">&nbsp;</td>
                                                                            <td colspan="2">Except</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="chkExcept1" runat="server" Text="common bile duct" /></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="chkExcept2" runat="server" Text="gall bladder" /></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="chkExcept3" runat="server" Text="common hepatic duct" /></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="chkExcept4" runat="server" Text="right hepatic duct" /></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td colspan="2">&nbsp;<asp:CheckBox ID="chkExcept5" runat="server" Text="left hepatic duct" /></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr id="AcinarTR" runat="server" style="display: none">
                                                                <td>&nbsp;<asp:CheckBox ID="chkAcinar1" runat="server" Text="Acinar filling" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table id="limitedtable" runat="server" cellspacing="0" cellpadding="0" border="0" style="display: none">
                                                                        <tr>
                                                                            <td style="width: 7px;">&nbsp;</td>
                                                                            <td><b>limited by:</b>&nbsp;</td>
                                                                            <td>
                                                                                <asp:RadioButton ID="optLB1" runat="server" Text="insufficient contrast injected" GroupName="optLimitedByHV" onclick="javascript:isoptLB2(this)" /></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td></td>
                                                                            <td>
                                                                                <div style="float: left; padding-right: 5px">
                                                                                    <asp:RadioButton ID="optLB2" runat="server" Text="other" GroupName="optLimitedByHV" onclick="javascript:isoptLB2(this)" />
                                                                                </div>
                                                                                <div id="optLB2Div" runat="server" style="display: none; float: left">
                                                                                    <telerik:RadComboBox ID="optLB2ComboBox" runat="server" Skin="Windows7" />
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </fieldset>
                                                </td>
                                                <td>
                                                    <fieldset style="width: 345px;">
                                                        <legend><b>Extent of pancreatic visualisation</b></legend>
                                                        <table id="pancreatictable" cellspacing="0" cellpadding="0" border="0" style="border: 0;">
                                                            <tr>
                                                                <td>&nbsp;<asp:CheckBox ID="pNotVisualisedCheckBox" runat="server" Text="Not visualised" />
                                                                    &nbsp;&nbsp;<asp:CheckBox ID="PancreasCheckBox" runat="server" Text="Pancreas divisum" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;<asp:CheckBox ID="WholeCheckBox" runat="server" Text="Whole pancreatic system visualised" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table id="tableMidSub3" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                                        <tr>
                                                                            <td style="width: 23px;">&nbsp;</td>
                                                                            <td colspan="2">Except</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox1" runat="server" Text="accessory pancreatic duct" /></td>
                                                                            <td>&nbsp;</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox2" runat="server" Text="main pancreatic duct" /></td>
                                                                            <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox3" runat="server" Text="uncinate process" /></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td colspan="2">
                                                                                <table id="tableMidSub4" cellspacing="0" cellpadding="0" border="0">
                                                                                    <tr>
                                                                                        <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox4" runat="server" Text="head" /></td>
                                                                                        <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox5" runat="server" Text="neck" /></td>
                                                                                        <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox6" runat="server" Text="body" /></td>
                                                                                        <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox7" runat="server" Text="tail" /></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr id="chkAcinar2TR" runat="server" style="display: none">
                                                                <td style="padding-left: 48px;">&nbsp;<asp:CheckBox ID="chkAcinar2" runat="server" Text="Acinar filling" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table id="limitedtable1" runat="server" cellspacing="0" cellpadding="0" border="0" style="display: none">
                                                                        <tr>
                                                                            <td style="width: 7px;">&nbsp;</td>
                                                                            <td><b>limited by:</b>&nbsp;</td>
                                                                            <td>
                                                                                <asp:RadioButton ID="optLimitedByPVButton" runat="server" Text="insufficient contrast injected" GroupName="optLimitedByPV" onclick="javascript:isoptLB0(this)" /></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td></td>
                                                                            <td>
                                                                                <div style="float: left; padding-right: 5px">
                                                                                    <asp:RadioButton ID="optOtherButton" runat="server" Text="other" GroupName="optLimitedByPV" onclick="javascript:isoptLB0(this)" />
                                                                                </div>
                                                                                <div id="optOtherDiv" runat="server" style="display: none; float: left">
                                                                                    <telerik:RadComboBox ID="optOtherComboBox" runat="server" Skin="Windows7" />
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </fieldset>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>

                                    <div id="ContrastMediaDiv" style="float: left;">
                                        <table id="tableBottom" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr style="vertical-align: top;">
                                                <td>
                                                    <fieldset style="width: 770px;">
                                                        <legend><b>Contrast media used</b></legend>
                                                        <table id="table5" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                            <tr>
                                                                <td style="width: 86px;">Hepatobiliary:</td>
                                                                <td style="width: 10px;">1st&nbsp;&nbsp;</td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="HepatobiliaryFirstComboBox" runat="server" Skin="Windows7" />
                                                                    &nbsp;&nbsp;<telerik:RadNumericTextBox ID="HepatobiliaryFirstMLTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" />&nbsp;ml </td>
                                                                <td style="width: 26px;">&nbsp;</td>
                                                                <td>2nd&nbsp;&nbsp;<telerik:RadComboBox ID="HepatobiliarySecondComboBox" runat="server" Skin="Office2007" />
                                                                    &nbsp;&nbsp;<telerik:RadNumericTextBox ID="HepatobiliarySecondMLRadTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" />&nbsp;ml</td>
                                                                

                                                            </tr>
                                                            <tr>
                                                                <td></td>
                                                                <td></td>
                                                                <td colspan="3">
                                                                    <asp:CheckBox ID="HepatobiliaryBalloonCheckBox" runat="server" Text="balloon catheter used (occlusion cholangiography)" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td>Pancreatic:</td>
                                                                <td>1st</td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="PancreaticFirstComboBox" runat="server" Skin="Office2007" />
                                                                    &nbsp;&nbsp;<telerik:RadNumericTextBox ID="PancreaticFirstMLTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" />&nbsp;ml</td>
                                                                <td>&nbsp;</td>
                                                                <td>2nd&nbsp;&nbsp;<telerik:RadComboBox ID="PancreaticSecondComboBox" runat="server" Skin="Office2007" />
                                                                    &nbsp;&nbsp;<telerik:RadNumericTextBox ID="PancreaticSecondMLTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" />&nbsp;ml</td>
                                                            </tr>
                                                            <tr>
                                                                <td></td>
                                                                <td></td>
                                                                <td colspan="3">
                                                                    <asp:CheckBox ID="PancreaticBalloonCheckBox" runat="server" Text="balloon catheter used (occlusion pancreatography)" /></td>
                                                            </tr>
                                                        </table>
                                                    </fieldset>
                                                </td>
                                            </tr>
                                        </table>

                                    </div>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>


                    </div>
                </div>
            </telerik:RadPane>

            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
                <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px;">
                    <telerik:RadButton ID="cmdAccept" runat="server" Text="Save & Close" ValidationGroup="SaveForm" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validateControls" OnClick="cmdAccept_Click" />
                    <telerik:RadButton ID="cmdCancel" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" OnClick="cancelRecord" />
                </div>
                <div style="height:0px; display:none">
                    <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" style="height:1px; width:1px" />
                </div>       
            </telerik:RadPane>
        </telerik:RadSplitter>
    </div>
    <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None"
        EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
        LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
        AutoCloseDelay="7000">
        <ContentTemplate>
            <asp:ValidationSummary ID="VisualisationValidationSummary" runat="server" ValidationGroup="SaveForm" DisplayMode="BulletList"
                EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
            <asp:Label ID="ValidationErrorLabel" runat="server" CssClass="aspxValidationSummary"></asp:Label>
        </ContentTemplate>
    </telerik:RadNotification>
</asp:Content>

