<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Visualisation.ascx.vb" Inherits="UnisoftERS.Visualisation" EnableViewState="True" %>


<telerik:RadScriptBlock runat="server" ID="radScriptsVisUC">
    <script type="text/javascript">
        $(document).ready(function () {
            $("[id$=optTD] input:radio").click(function () {
                if ($("#<%= optVA2.ClientID%>").is(':checked')) { $("#<%= optDiv.ClientID%>").show(); } else { $("#<%= optDiv.ClientID%>").hide(); $find('<%= cboAccessViaOther.ClientID%>').clearSelection(); }
            });
        });

    </script>
    <style type="text/css">
        .visTable{
            /*border:0; border-spacing:0; border-color:#FFF;*/
            width:800px; box-sizing:content-box; margin-top:1em;
        }

        .visTable td {
                /*padding:3px 5px;*/
            }
    </style>
</telerik:RadScriptBlock>

<asp:Panel ID="panVisualisationFormView" runat="server" style="width:800px;">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

<%--    <telerik:radsplitter id="mainpageradsplitter" runat="server" width="100%" height="100%" orientation="horizontal" bordersize="0" panesbordersize="0" skin="Web20">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Width="100%" Scrolling="Y">--%>
            <div id="ContentDiv" class="siteDetailsContentDiv" style="overflow: auto; width:820px; margin:5px 0 0 5px; ">
                    <div class="" id="rgVisualisation" runat="server">
                        <table id="table1" runat="server" cellspacing="0" cellpadding="0" border="0" >
                            <tr style="vertical-align: top;">
                                <td style="width:465px">
                                    <fieldset style="margin: 0px 5px; width: 430px;">
                                        <legend><b>Access via</b></legend>
                                        <table id="tableAccessVia" cellpadding="1" cellspacing="1" border="0">
                                            <tr>
                                                <td style="width: 5px;"></td>
                                                <%--<td>Access via</td>--%>
                                                <td id="optTD">
                                                    <div style="float: left; padding-right: 25px">
                                                        <asp:RadioButton ID="optAV1" runat="server" Text="pylorus" GroupName="optAccessVia" />
                                                    </div>
                                                    <div style="float: left; padding-right: 5px">
                                                        <asp:RadioButton ID="optVA2" runat="server" Text="other" GroupName="optAccessVia" />
                                                    </div>
                                                    <div id="optDiv" runat="server" style="display: none; float: left">
                                                        <telerik:RadComboBox ID="cboAccessViaOther" runat="server" Skin="Office2007" AllowCustomText="true" />
                                                    </div>

                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td>
                                    <fieldset style="margin: 0px 5px; width: 280px;">
                                        <legend><b>Procedure</b></legend>
                                        <table cellpadding="1" cellspacing="1" border="0" style="width:100%;">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="AbandonedCheckBox" runat="server" Text="Procedure abandoned" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                        <table id="tableTop" runat="server" cellspacing="0" cellpadding="0" border="0" class="visTable">
                            <tr style="vertical-align: top;">
                                <td style="width:475px;">
                                    <fieldset style="margin: 0px 5px; width: 430px;">
                                        <legend><b>Cannulation via major papilla</b></legend>
                                        <table id="majortable" runat="server" cellspacing="0" cellpadding="0" border="0"  style="width:100%;">
                                            <tr>
                                                <td style="width: 50%"><b>to bile duct was..</b></td>
                                                <td><b>to pancreatic duct was..</b></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optBile1" runat="server" Text="successful" GroupName="optBileDuct" /></td>
                                                <td>&nbsp;<asp:RadioButton ID="optPan1" runat="server" Text="successful" GroupName="optPanDuct" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optBile2" runat="server" Text="partially successful" GroupName="optBileDuct" /></td>
                                                <td>&nbsp;<asp:RadioButton ID="optPan2" runat="server" Text="partially successful" GroupName="optPanDuct" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optBile3" runat="server" Text="not attempted" GroupName="optBileDuct" /></td>
                                                <td>&nbsp;<asp:RadioButton ID="optPan3" runat="server" Text="not attempted" GroupName="optPanDuct" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optBile4" runat="server" Text="unsuccessful due to" GroupName="optBileDuct" /></td>
                                                <td>&nbsp;<asp:RadioButton ID="optPan4" runat="server" Text="unsuccessful due to" GroupName="optPanDuct" /></td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" style="height: 4px;"></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="BileReasonsDiv1" runat="server" style="display: none; padding-right: 5px">
                                                        <label>Using</label> <telerik:RadComboBox ID="cboBileReasons1" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                    <div id="BileReasonsDiv2" runat="server" style="display: none; padding-right: 5px">
                                                        <label>(reason)</label> <telerik:RadComboBox ID="cboBileReasons2" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                    <div id="BileReasonsDiv4" runat="server" style="display: none; padding-right: 5px">
                                                        <telerik:RadComboBox ID="cboBileReasons4" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <div id="PancreaticReasonsDiv1" runat="server" style="display: none">
                                                        <label>Using</label> <telerik:RadComboBox ID="cboPancreaticReasons1" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                    <div id="PancreaticReasonsDiv2" runat="server" style="display: none">
                                                        <label>(reason)</label> <telerik:RadComboBox ID="cboPancreaticReasons2" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                    <div id="PancreaticReasonsDiv4" runat="server" style="display: none">
                                                        <telerik:RadComboBox ID="cboPancreaticReasons4" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td style="width:330px;">
                                    <fieldset style="margin: 0px 5px; width: 280px">
                                        <legend><b>Cannulation via minor papilla</b></legend>
                                        <table id="minortable" cellspacing="0" cellpadding="0" border="0" style="width:100%;">
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optMinorPap1" runat="server" Text="successful" GroupName="optMinorPapilla" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optMinorPap2" runat="server" Text="partially successful" GroupName="optMinorPapilla" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optMinorPap3" runat="server" Text="not attempted" GroupName="optMinorPapilla" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:RadioButton ID="optMinorPap4" runat="server" Text="unsuccessful due to" GroupName="optMinorPapilla" /></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="MinorPapReasonsDiv1" runat="server" style="display: none">
                                                        <label>Using</label>
                                                        <telerik:RadComboBox ID="cboMinorPapReasons1" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                    <div id="MinorPapReasonsDiv2" runat="server" style="display: none">
                                                        <label>(reason)</label>
                                                        <telerik:RadComboBox ID="cboMinorPapReasons2" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                    <div id="MinorPapReasonsDiv4" runat="server" style="display: none">
                                                        <telerik:RadComboBox ID="cboMinorPapReasons4" runat="server" Skin="Windows7" AllowCustomText="true" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                        <table id="tableMiddle" runat="server" cellspacing="0" cellpadding="0" border="0" class="visTable">
                            <tr style="vertical-align: top;">
                                <td style="width:400px;">
                                    <fieldset style="margin: 0px 5px; width: 365px;">
                                        <legend><b>Extent of hepatobiliary visualisation</b></legend>
                                        <table id="hepatobiliarytable" cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td>&nbsp;<asp:CheckBox ID="chkHVNotVisualised" runat="server" Text="Not visualised" /></td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;<asp:CheckBox ID="chkHVWholeBiliary" runat="server" Text="Whole biliary system visualised" /></td>
                                            </tr>
                                            <tr>
                                                <td >
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
                                                                    <telerik:RadComboBox ID="optLB2ComboBox" runat="server" Skin="Windows7" AllowCustomText="true" />
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
                                    <fieldset style="margin: 0px 5px; width: 345px;">
                                        <legend><b>Extent of pancreatic visualisation</b></legend>
                                        <table id="pancreatictable" cellspacing="0" cellpadding="0" border="0" style="border:0;">
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
                                                <td style="padding-left:48px;">&nbsp;<asp:CheckBox ID="chkAcinar2" runat="server" Text="Acinar filling" /></td>
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
                                                                    <telerik:RadComboBox ID="optOtherComboBox" runat="server" Skin="Windows7" AllowCustomText="true" />
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
                        <table id="tableBottom" runat="server" cellspacing="0" cellpadding="0" border="0" class="visTable">
                            <tr style="vertical-align: top;">
                                <td>
                                    <fieldset style="margin: 0px 5px; width: 755px; height: 100%;">
                                        <legend><b>Contrast media used</b></legend>
                                        <table id="table5" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td style="width: 86px;">Hepatobiliary:</td>
                                                <td style="width: 10px;">1st&nbsp;&nbsp;</td>
                                                <td>
                                                    <telerik:RadComboBox ID="HepatobiliaryFirstComboBox" runat="server" Skin="Office2007" AllowCustomText="true" />
                                                    &nbsp;&nbsp;<telerik:RadTextBox ID="HepatobiliaryFirstMLTextBox" runat="server" Skin="Office2007" Width="40" />&nbsp;ml</td>
                                                <td style="width: 26px;">&nbsp;</td>
                                                <td>2nd&nbsp;&nbsp;<telerik:RadComboBox ID="HepatobiliarySecondComboBox" runat="server" Skin="Office2007" AllowCustomText="true" />
                                                    &nbsp;&nbsp;<telerik:RadTextBox ID="HepatobiliarySecondMLRadTextBox" runat="server" Skin="Office2007" Width="40" />&nbsp;ml</td>
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
                                                    <telerik:RadComboBox ID="PancreaticFirstComboBox" runat="server" Skin="Office2007" AllowCustomText="true" />
                                                    &nbsp;&nbsp;<telerik:RadTextBox ID="PancreaticFirstMLTextBox" runat="server" Skin="Office2007" Width="40" />&nbsp;ml</td>
                                                <td>&nbsp;</td>
                                                <td>2nd&nbsp;&nbsp;<telerik:RadComboBox ID="PancreaticSecondComboBox" runat="server" Skin="Office2007" AllowCustomText="true" />
                                                    &nbsp;&nbsp;<telerik:RadTextBox ID="PancreaticSecondMLTextBox" runat="server" Skin="Office2007" Width="40" />&nbsp;ml</td>
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
                        <div>&nbsp;<asp:HiddenField ID="hiddenCarriedRoleOut" runat="server" Value="1" />
                        </div>
                    </div>
                </div>

<%--        </telerik:RadPane>
    </telerik:RadSplitter>--%>
    <%--</div>--%> <%--rgAbnormalities--%>
    <%--</div>--%>  <%--siteDetailsContentDiv--%>
    <%--</div> ContentsDiv --%>
</asp:Panel>
