<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Cannulation.ascx.vb" Inherits="UnisoftERS.Cannulation" %>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<script type="text/javascript">
    var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
    var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

    $(window).on('load', function () {

    });

    $(document).ready(function () {
        SetAccessViaOther();

        $('.cb-control input').click(function () {
            saveData();
        });

        $("[id$=AccessViaDiv] input:radio").click(function () {
            SetAccessViaOther();

            saveData();
        });

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

            saveData();
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
            saveData();
        });


        $("[id^=hepatobiliarytable] input:checkbox").click(function (sender) {
            var v = $(this).attr("id");
            var ucPrefix = GetThisPrefix($(this).attr("id"));
            if ($(this).is(':checked')) {
                if (v.endsWith("chkHVNotVisualised")) {
                    $(ucPrefix + "chkHVWholeBiliary").prop('checked', false);
                    $(ucPrefix + "AcinarTR input:checkbox").prop('checked', false);  // uncheck AcinarTR by Ferdowsi
                    SetCheckBoxChecked(ucPrefix + 'chkExcept', 5, true); //## Check chkExcept1 to 5
                    $(ucPrefix + "limitedtable").show();
                    $(ucPrefix + "limitedtable input:radio").prop('checked', false);
                    $(ucPrefix + "AcinarTR").hide();
                    $find("<%= optLB2ComboBox.ClientID %>").clearSelection();
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
                    $find("<%= optLB2ComboBox.ClientID %>").clearSelection();
                }          }

            saveData();
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
                    $(ucPrefix + "chkAcinar2TR input:checkbox").prop('checked', false); // uncheck AcinarT2R by Ferdowsi
                    $(ucPrefix + "limitedtable1 input:radio").prop('checked', false);
                    $(ucPrefix + "chkAcinar2TR").hide();
                    $find("<%= optOtherComboBox.ClientID %>").clearSelection();
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
                    $find("<%= optOtherComboBox.ClientID %>").clearSelection();
                }
            }

            saveData();
        });

        $('#DuodenumTable input[type=checkbox]').change(function () {
            if (this.id.indexOf("Duodenum2ndPartNotEnteredCheckBox") >= 0 || this.id.indexOf("DuodenumNormalCheckBox") >= 0 || this.id.indexOf("DuodenumNotEnteredCheckBox") >= 0) {
                $('#DuodenumTable input[type=checkbox]').not("[id*='" + this.id + "']").prop('checked', false);
            }

            saveData();
        });

        $("[id$=ER_Sphincterotomytable] input:radio").click(function (sender) {
            var v = $(this).val(); var c = $(this).is(':checked');
            var ucPrefix = GetThisPrefix($(this).attr("id"));
            var selectedId = $(this).attr('id');

            var matches = selectedId.match(/(\d+)/);
            var idValue = matches ? parseInt(matches[0], 10) : null;

            if (selectedId.includes('optSphincterotomy4_ER')) {
                $(ucPrefix + "SphincterotomyOtherDiv").show();
            } else {
                $(ucPrefix + "SphincterotomyOtherDiv").hide();
                $(ucPrefix + "SphincterotomyOtherTextBox").val('');
            }

            saveData();
        });

    });

    function isoptLB0(sender) {
        var thisId = $(sender).attr('id');
        var optOtherDiv = GetThisPrefix($(sender).attr('id')) + 'optOtherDiv';  //## This is our Target div to Hide-> [Option Limited By-> Other]
        if (thisId.indexOf("optOtherButton") >= 0) {
            $(optOtherDiv).show();
        } else {
            $(optOtherDiv).hide();
        }
        saveData();
    }

    function SetAccessViaOther() {
        if ($("#<%= optVA2.ClientID%>").is(':checked')) {
            $("#<%= cboAccessViaOther.ClientID%>").show();
        } else {
            $("#<%= cboAccessViaOther.ClientID%>").hide();
                //$find('<%= cboAccessViaOther.ClientID%>').clearSelection();
        }
    }

    function GetThisPrefix(controlName) {
        return controlName.indexOf("_ER") > 0 ? "#ProcCannulation_ER_" : "#ProcCannulation_";
    }

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

        saveData();
    }

    function saveData() {
        $find("<%=RadAjaxManager1.ClientID%>").ajaxRequest();
        setRehideSummary();

    }
</script>

<style>
    .control-sub-header {
        width: 90% !important; /*for this page only*/
    }
    #ProcCannulation_SphincterotomyOtherTextBox_wrapper{
        padding-top: 10px;
    }
    #ProcCannulation_SphincterotomyOtherTextBox{
        border-color: #000 !important;
    }
</style>

<telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
<div class="control-section-header abnorHeader" id="CannulationLabel" runat="server">Visualisation</div>
<div class="control-sub-header">Access via</div>
<div id="AccessViaDiv" style="padding: 15px;">
    <table>
        <tr>
            <td></td>
            <td>
                <asp:RadioButton ID="optAV1" runat="server" Text="pylorus" GroupName="optAccessVia" />
                <span style="padding-left: 20px;" />
                <asp:RadioButton ID="optVA2" runat="server" Text="other" GroupName="optAccessVia" />
                <telerik:RadComboBox ID="cboAccessViaOther" runat="server" Skin="Office2007" OnClientSelectedIndexChanged="saveData" />
            </td>
        </tr>
        <tr>
            <td colspan="2" style="height: 4px;"></td>
        </tr>
    </table>
</div>
<div class="control-sub-header">Duodenum</div>
<div style="padding: 15px;">
    <table id="DuodenumTable">

        <tr>
            <td></td>
            <td>
                <asp:CheckBox ID="DuodenumNormalCheckBox" runat="server" Text="Normal" Visible="false" />
                <span style="/*padding-left: 20px; */" />
                <asp:CheckBox ID="DuodenumNotEnteredCheckBox" runat="server" Text="Not Entered" />
                <span style="padding-left: 20px;" />
                <asp:CheckBox ID="Duodenum2ndPartNotEnteredCheckBox" runat="server" Text="2nd Part Not Entered" />
                <span style="padding-left: 20px;" />
                <asp:CheckBox ID="AmupllaNotEnteredCheckBox" runat="server" Text="Ampulla Not Visualised" />
            </td>
        </tr>
    </table>
</div>
<div style="padding: 15px;">
    <table style="width: 100%;">
        <tr>
            <td id="tdTrainER" runat="server">
                <asp:Label ID="lblTrainERName" runat="server" Font-Size="14px" Font-Bold="true" /><br />
                <br />
                <asp:CheckBox ID="Abandoned_ER_CheckBox" runat="server" Text="Procedure abandoned" CssClass="cb-control" />
                <br />
                <div class="control-sub-header">Intended duct for cannulation</div>
                <div class="control-content">
                    <table>
                        <tr>
                            <td>
                                <asp:CheckBox ID="IntendedBileDuct_ER_CheckBox" runat="server" Text="Bile duct" CssClass="bile-duct-cb intended-duct-cb cb-control" /></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="IntendedPancreaticDuct_ER_CheckBox" runat="server" Text="Pancreatic duct" CssClass="pancreatic-duct-cb intended-duct-cb cb-control" /></td>
                        </tr>
                    </table>
                </div>

                <div class="control-sub-header">Cannulation via major papilla</div>
                <div class="control-content">
                    <table id="ER_Majortable">
                        <tr>
                            <td class="" style="width: 50%"><b>to bile duct was..</b></td>

                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile1_ER" runat="server" Text="successful" CssClass="optBileDuct" GroupName="optBileDuct_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile2_ER" runat="server" Text="partially successful" CssClass="optBileDuct" GroupName="optBileDuct_ER" /></td>

                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile3_ER" runat="server" Text="not attempted" CssClass="optBileDuct" GroupName="optBileDuct_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile4_ER" runat="server" Text="unsuccessful due to" CssClass="optBileDuct" GroupName="optBileDuct_ER" /></td>

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
                        </tr>
                        <tr>
                            <td class=""><b>to pancreatic duct was..</b></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan1_ER" runat="server" Text="successful" CssClass="optPanDuct" GroupName="optPanDuct_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan2_ER" runat="server" Text="partially successful" CssClass="optPanDuct" GroupName="optPanDuct_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan3_ER" runat="server" Text="not attempted" CssClass="optPanDuct" GroupName="optPanDuct_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan4_ER" runat="server" Text="unsuccessful due to" CssClass="optPanDuct" GroupName="optPanDuct_ER" /></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 4px;"></td>
                        </tr>
                        <tr>
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
                </div>

                <div class="control-sub-header">Cannulation via minor papilla</div>
                <div class="control-content">
                    <table id="ER_Minortable" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap1_ER" runat="server" Text="successful" CssClass="optMinorPapilla" GroupName="optMinorPapilla_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap2_ER" runat="server" Text="partially successful" CssClass="optMinorPapilla" GroupName="optMinorPapilla_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap3_ER" runat="server" Text="not attempted" CssClass="optMinorPapilla" GroupName="optMinorPapilla_ER" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap4_ER" runat="server" Text="unsuccessful due to" CssClass="optMinorPapilla" GroupName="optMinorPapilla_ER" /></td>
                        </tr>
                        <tr>
                            <td>
                                <div id="ER_MinorPapReasonsDiv1" runat="server" style="display: none">
                                    <label>Using</label>
                                    <telerik:RadComboBox ID="cboMinorPapReasons1_ER" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="ER_MinorPapReasonsDiv2" runat="server" style="display: none">
                                    <label>(reason)</label>
                                    <telerik:RadComboBox ID="cboMinorPapReasons2_ER" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="ER_MinorPapReasonsDiv4" runat="server" style="display: none">
                                    <telerik:RadComboBox ID="cboMinorPapReasons4_ER" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>

                <div class="control-sub-header">Number of attempts of sphincterotomy</div>
                 <div class="control-content">
                     <table id="ER_Sphincterotomytable" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                         <tr>
                             <td>&nbsp;<asp:RadioButton ID="optSphincterotomy1_ER" runat="server" Text="Single" CssClass="optMinorPapilla" GroupName="optSphincterotomy" /></td>
                         </tr>
                         <tr>
                             <td>&nbsp;<asp:RadioButton ID="optSphincterotomy2_ER" runat="server" Text="Few" CssClass="optMinorPapilla" GroupName="optSphincterotomy" /></td>
                         </tr>
                         <tr>
                             <td>&nbsp;<asp:RadioButton ID="optSphincterotomy3_ER" runat="server" Text="Prolonged" CssClass="optMinorPapilla" GroupName="optSphincterotomy" /></td>
                         </tr>
                         <tr>
                             <td>&nbsp;<asp:RadioButton ID="optSphincterotomy4_ER" runat="server" Text="Other" CssClass="optMinorPapilla" GroupName="optSphincterotomy" /></td>
                         </tr>
                         <tr>
                             <td>
                                 <div id="ER_SphincterotomyOtherDiv" runat="server" visible="false">
                                     <telerik:RadTextBox ID="ER_SphincterotomyOtherTextBox" runat="server" Width="50%" ClientEvents-OnValueChanged="saveData" />
                                 </div>
                             </td>
                         </tr>
                     </table>
                 </div>
                
            <td id="tdTrainEE" runat="server">
                <asp:Label ID="lblTrainEEName" runat="server" Font-Size="14px" Font-Bold="true" /><br />
                <br />
                <asp:CheckBox ID="AbandonedCheckBox" runat="server" Text="Procedure abandoned" CssClass="cb-control" />
                <br />
                <div class="control-sub-header">Intended duct for cannulation</div>
                <div class="control-content">
                    <table>
                        <tr>
                            <td>
                                <asp:CheckBox ID="IntendedBileDuctCheckBox" runat="server" Text="Bile duct" CssClass="bile-duct-cb intended-duct-cb cb-control" /></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="IntendedPancreaticDuctCheckBox" runat="server" Text="Pancreatic duct" CssClass="pancreatic-duct-cb intended-duct-cb cb-control" /></td>
                        </tr>
                    </table>
                </div>

                <div class="control-sub-header">Cannulation via major papilla</div>
                <div class="control-content">
                    <table id="Majortable">
                        <tr>
                            <td class="" style="width: 50%"><b>to bile duct was..</b></td>

                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile1" runat="server" Text="successful" CssClass="optBileDuct" GroupName="optBileDuct" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile2" runat="server" Text="partially successful" CssClass="optBileDuct" GroupName="optBileDuct" /></td>

                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile3" runat="server" Text="not attempted" CssClass="optBileDuct" GroupName="optBileDuct" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optBile4" runat="server" Text="unsuccessful due to" CssClass="optBileDuct" GroupName="optBileDuct" /></td>

                        </tr>
                        <tr>
                            <td colspan="2" style="height: 4px;"></td>
                        </tr>
                        <tr>
                            <td>
                                <div id="BileReasonsDiv1" runat="server" style="display: none; padding-right: 5px">
                                    <label>Using</label>
                                    <telerik:RadComboBox ID="cboBileReasons1" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="BileReasonsDiv2" runat="server" style="display: none; padding-right: 5px">
                                    <label>(reason)</label>
                                    <telerik:RadComboBox ID="cboBileReasons2" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="BileReasonsDiv4" runat="server" style="display: none; padding-right: 5px">
                                    <telerik:RadComboBox ID="cboBileReasons4" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class=""><b>to pancreatic duct was..</b></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan1" runat="server" Text="successful" CssClass="optPanDuct" GroupName="optPanDuct" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan2" runat="server" Text="partially successful" CssClass="optPanDuct" GroupName="optPanDuct" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan3" runat="server" Text="not attempted" CssClass="optPanDuct" GroupName="optPanDuct" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optPan4" runat="server" Text="unsuccessful due to" CssClass="optPanDuct" GroupName="optPanDuct" /></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 4px;"></td>
                        </tr>
                        <tr>
                            <td>
                                <div id="PancreaticReasonsDiv1" runat="server" style="display: none">
                                    <label>Using</label>
                                    <telerik:RadComboBox ID="cboPancreaticReasons1" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="PancreaticReasonsDiv2" runat="server" style="display: none">
                                    <label>(reason)</label>
                                    <telerik:RadComboBox ID="cboPancreaticReasons2" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="PancreaticReasonsDiv4" runat="server" style="display: none">
                                    <telerik:RadComboBox ID="cboPancreaticReasons4" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>

                <div class="control-sub-header">Cannulation via minor papilla</div>
                <div class="control-content">
                    <table id="Minortable" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap1" runat="server" Text="successful" CssClass="optMinorPapilla" GroupName="optMinorPapilla" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap2" runat="server" Text="partially successful" CssClass="optMinorPapilla" GroupName="optMinorPapilla" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap3" runat="server" Text="not attempted" CssClass="optMinorPapilla" GroupName="optMinorPapilla" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;<asp:RadioButton ID="optMinorPap4" runat="server" Text="unsuccessful due to" CssClass="optMinorPapilla" GroupName="optMinorPapilla" /></td>
                        </tr>
                        <tr>
                            <td>
                                <div id="MinorPapReasonsDiv1" runat="server" style="display: none">
                                    <label>Using</label>
                                    <telerik:RadComboBox ID="cboMinorPapReasons1" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="MinorPapReasonsDiv2" runat="server" style="display: none">
                                    <label>(reason)</label>
                                    <telerik:RadComboBox ID="cboMinorPapReasons2" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                                <div id="MinorPapReasonsDiv4" runat="server" style="display: none">
                                    <telerik:RadComboBox ID="cboMinorPapReasons4" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>


            </td>
                
            </td>
        </tr>
    </table>
</div>


<div class="control-sub-header">Extent of hepatobiliary visualisation</div>
<div style="padding: 15px;">
    <table id="hepatobiliarytable" cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
        <tr>
            <td>&nbsp;<asp:CheckBox ID="chkHVNotVisualised" runat="server" Text="Not visualised" /></td>
        </tr>
        <tr>
            <td>&nbsp;<asp:CheckBox ID="chkHVWholeBiliary" runat="server" Text="Whole biliary system visualised" /></td>
        </tr>
        <tr>
            <td>
                <table id="tableMidSub1" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-left: 30px;">
                    <tr>
                        <td colspan="2">Except</td>
                    </tr>
                    <tr>
                        <td>&nbsp;<asp:CheckBox ID="chkExcept1" runat="server" Text="common bile duct" /></td>

                        <td>&nbsp;<asp:CheckBox ID="chkExcept2" runat="server" Text="gall bladder" /></td>
                    </tr>
                    <tr>
                        <td>&nbsp;<asp:CheckBox ID="chkExcept3" runat="server" Text="common hepatic duct" /></td>

                        <td>&nbsp;<asp:CheckBox ID="chkExcept4" runat="server" Text="right hepatic duct" /></td>
                    </tr>
                    <tr>
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
                                <telerik:RadComboBox ID="optLB2ComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>

<div class="control-sub-header">Extent of pancreatic visualisation</div>
<div style="padding: 15px;">
    <table id="pancreatictable" cellspacing="0" cellpadding="0" border="0" style="border: 0; width: 100%;">
        <tr>
            <td>&nbsp;<asp:CheckBox ID="pNotVisualisedCheckBox" runat="server" Text="Not visualised" />
                &nbsp;&nbsp;<asp:CheckBox ID="PancreasCheckBox" runat="server" Text="Pancreas divisum" /></td>
        </tr>
        <tr>
            <td>&nbsp;<asp:CheckBox ID="WholeCheckBox" runat="server" Text="Whole pancreatic system visualised" /></td>
        </tr>
        <tr>
            <td>
                <table id="tableMidSub3" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-left: 30px;">
                    <tr>
                        <td colspan="2">Except</td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;<asp:CheckBox ID="ExceptCheckBox1" runat="server" Text="accessory pancreatic duct" /></td>
                    </tr>
                    <tr>
                        <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox2" runat="server" Text="main pancreatic duct" /></td>
                        <td>&nbsp;<asp:CheckBox ID="ExceptCheckBox3" runat="server" Text="uncinate process" /></td>
                    </tr>
                    <tr>
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
            <td>&nbsp;<asp:CheckBox ID="chkAcinar2" runat="server" Text="Acinar filling" /></td>
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
                                <telerik:RadComboBox ID="optOtherComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>


<div class="control-sub-header">Contrast media used</div>
<div style="padding: 15px;">
    <table id="table5" runat="server" cellspacing="0" cellpadding="0" border="0">
        <tr>
            <td style="width: 86px;">Hepatobiliary:</td>
            <td style="width: 10px;">1st&nbsp;&nbsp;</td>
            <td>
                <telerik:RadComboBox ID="HepatobiliaryFirstComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="saveData" />
                &nbsp;&nbsp;<telerik:RadNumericTextBox ID="HepatobiliaryFirstMLTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" ClientEvents-OnValueChanged="saveData" />&nbsp;ml </td>
            <td style="width: 26px;">&nbsp;</td>
            <td>2nd&nbsp;&nbsp;<telerik:RadComboBox ID="HepatobiliarySecondComboBox" runat="server" Skin="Office2007" OnClientSelectedIndexChanged="saveData" />
                &nbsp;&nbsp;<telerik:RadNumericTextBox ID="HepatobiliarySecondMLRadTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" ClientEvents-OnValueChanged="saveData" />&nbsp;ml</td>


        </tr>
        <tr>
            <td></td>
            <td></td>
            <td colspan="3">
                <asp:CheckBox ID="HepatobiliaryBalloonCheckBox" runat="server" Text="balloon catheter used (occlusion cholangiography)" CssClass="cb-control" /></td>
        </tr>
        <tr>
            <td>Pancreatic:</td>
            <td>1st</td>
            <td>
                <telerik:RadComboBox ID="PancreaticFirstComboBox" runat="server" Skin="Office2007" OnClientSelectedIndexChanged="saveData" />
                &nbsp;&nbsp;<telerik:RadNumericTextBox ID="PancreaticFirstMLTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" ClientEvents-OnValueChanged="saveData" />&nbsp;ml</td>
            <td>&nbsp;</td>
            <td>2nd&nbsp;&nbsp;<telerik:RadComboBox ID="PancreaticSecondComboBox" runat="server" Skin="Office2007" OnClientSelectedIndexChanged="saveData" />
                &nbsp;&nbsp;<telerik:RadNumericTextBox ID="PancreaticSecondMLTextBox" runat="server" Skin="Office2007" Width="35" NumberFormat-DecimalDigits="0" MinValue="0" MaxValue="300" ClientEvents-OnValueChanged="saveData" />&nbsp;ml</td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td colspan="3">
                <asp:CheckBox ID="PancreaticBalloonCheckBox" runat="server" Text="balloon catheter used (occlusion pancreatography)" CssClass="cb-control" /></td>
        </tr>
    </table>
</div>
<telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
    <Windows>
        <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
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
    </Windows>
</telerik:RadWindowManager>
