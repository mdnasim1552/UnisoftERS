<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Biliary.aspx.vb" Inherits="UnisoftERS.Biliary" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .IntraExtrahepticTable td {
            border: 0px;
        }

        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }

        .rblType td {
            border: none;
            padding-left: 0px;
        }

        .rblType label {
            margin-right: 20px;
        }

        div.RadToolBar_Horizontal .rtbSeparator {
            width: 20px;
            background: none;
            border: none;
        }

        .divChildControl {
            float: left;
            margin-left: 30px;
        }
    </style>

    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

            $(window).on('load', function () {
                $('#BiliaryTable tr td input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });

                ToggleBiliaryDivs();

            });

            function ToggleBiliaryDivs() {
                if ($("#<%=D220P2_CheckBox.ClientID%>").is(':checked')) {
                    $("#<%= BiliaryLeakDiv.ClientID%>").show();
                    $(this).siblings('label').html('Biliary leak -site');
                } else {
                    $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                    $(this).siblings('label').html('Biliary leak');
                }

                if ($("#<%=D280P2_CheckBox.ClientID%>").is(':checked')) {
                    $("#<%= ExtrahepaticLeakDiv.ClientID%>").show();
                    $(this).siblings('label').html('Biliary leak -site');
                } else {
                    $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                    $(this).siblings('label').html('Biliary leak');
                }
            }

            $(document).ready(function () {
                $("#BiliaryTable tr td:first-child input:checkbox").change(function () {
                    ToggleTRs($(this));
                });

                $("#NormalCheckBox").change(function () {
                    ToggleNormalCheckBox($(this).is(':checked'));
                });

                $("#<%= D220P2_CheckBox.ClientID%>").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= BiliaryLeakDiv.ClientID%>").show();
                        $(this).siblings('label').html('Biliary leak -site');
                    } else {
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        $(this).siblings('label').html('Biliary leak');
                    }
                });

                $("#<%= D280P2_CheckBox.ClientID%>").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").show();
                        $(this).siblings('label').html('Biliary leak -site');
                    } else {
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        $(this).siblings('label').html('Biliary leak');
                    }
                });

                 <%'---D265P2_CheckBox is ExtrahepaticNormalCheckBox -- %>
                $("#<%= D265P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D265P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#ExtrahepaticTable input:checkbox, #ExtrahepaticTable input:radio").prop('checked', false);
                        $("#ExtrahepaticTable input:text").val('');
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").hide(); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%>").hide(); $("#<%= MalignantTR.ClientID%>").hide();
                    }
                });

                $("#ExtrahepaticTable input:checkbox , #ExtrahepaticTable input:radio, #ExtrahepaticTable input:text").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D265P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                    if ($(this).val() != null && $(this).val() != "") { $("#<%= D265P2_CheckBox.ClientID%>").prop('checked', false); }
                });

                <%'---D198P2_CheckBox is NormalDuctsCheckBox -- %>
                $("#<%= D198P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D198P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#IntrahepaticTable input:checkbox, #IntrahepaticTable input:radio").prop('checked', false);
                        $("#IntrahepaticTable input:text").val('');
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        <%--$("#<%= IntrahepaticTumourDiv.ClientID%>").hide(); $("#<%= IntrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false);
                        $("#<%= IntrahepaticTumourTypeTR.ClientID%>").hide(); $("#<%= IntrahepaticTumourTypeTR.ClientID%> input:checkbox").prop('checked', false);--%>
                    }
                });

                $("#IntrahepaticTable input:checkbox , #IntrahepaticTable input:radio, #IntrahepaticTable input:text").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D198P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                    if ($(this).val() != null && $(this).val() != "") { $("#<%= D198P2_CheckBox.ClientID%>").prop('checked', false); }
                });

                <%'---D220P2_CheckBox is BiliaryLeakSiteCheckBox -- %>
                $("#<%= D220P2_CheckBox.ClientID%>").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= BiliaryLeakDiv.ClientID%>").show();
                        $(this).siblings('label').html('Biliary leak -site');
                    } else {
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        $(this).siblings('label').html('Biliary leak');
                    }
                });

                <%'---D280P2_CheckBox is ExtrahepaticLeakSiteCheckBox -- %>
                $("#<%= D280P2_CheckBox.ClientID%>").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").show();
                        $(this).siblings('label').html('Biliary leak -site');
                    } else {
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        $(this).siblings('label').html('Biliary leak');
                    }
                });

                <%'---D290P2_CheckBox is ExtrahepaticTumourCheckBox -- %>
                $("#<%= D290P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D290P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").show();
                    } else {
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").hide(); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%>").hide(); $("#<%= MalignantTR.ClientID%>").hide();
                    }
                });

                $("#<%= ExtrahepaticTumourRadioButtonList.ClientID%>").click(function () {
                    var v = $(this).find('input:checked').val();
                    if (v == 1) {
                        $("#<%= BeningTR.ClientID%>").show(); $("#<%= MalignantTR.ClientID%>").hide();
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                    } else if (v == 2) {
                        $("#<%= MalignantTR.ClientID%>").show(); $("#<%= BeningTR.ClientID%>").hide();
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                    }
                });
            });

            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function ToggleTRs(chkbox) {
                if (chkbox[0].id != "NormalCheckBox") {
                    var checked = chkbox.is(':checked');
                    if (checked) {
                        $("#NormalCheckBox").attr('checked', false);
                    }
                    chkbox.closest('td')
                        .nextUntil('tr').each(function () {
                            if (checked) {
                                $(this).show();
                            }
                            else {
                                $(this).hide();
                                ClearControls($(this));
                            }
                        });
                    var subRows = chkbox.closest('td').closest('tr').attr('hasChildRows');
                    if (typeof subRows !== typeof undefined && subRows == "1") {
                        chkbox.closest('tr').nextUntil('tr [headRow="1"]').each(function () {
                            if (checked) {
                                $(this).show();
                            }
                            else {
                                $(this).hide();
                                ClearControls($(this));
                            }
                        });
                    }
                }
            }

            function ToggleNormalCheckBox(checked) {
                if (checked) {
                    $("#BiliaryTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").removeAttr("checked");
                        $(this).find("input:checkbox").trigger("change");
                    });
                }
            }

            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").removeAttr("checked");
                tableCell.find("input:checkbox:checked").removeAttr("checked");
                tableCell.find("input:text").val("");
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

        </script>
    </telerik:RadScriptBlock>  
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="DuctRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DuctRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">
            <asp:Label ID="HeadingLabel" runat="server" Text="Biliary"></asp:Label>
        </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="BiliaryTable" class="rgview" cellpadding="0" cellspacing="0" width="95%">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NormalCheckBox" runat="server" Text="Normal" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="AnastomicStrictureCheckBox" runat="server" Text="Anastomic stricture" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="CalculousObstructionCheckBox" runat="server" Text="Calculous obstruction of cystic duct" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="CholelithiasisCheckBox" runat="server" Text="Cholelithiasis" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="GallBladderTumourCheckBox" runat="server" Text="Gall bladder tumour" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="HaemobiliaCheckBox" runat="server" Text="Haemobilia" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="MirizziSyndromeCheckBox" runat="server" Text="Mirizzi syndrome" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="OcclusionCheckBox" runat="server" Text="Occlusion" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="StentOcclusionCheckBox" runat="server" Text="Stent occlusion" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                            <table class="IntraExtrahepticTable" style="width: 95%;">
                                <tr>
                                    <td>
                                        <fieldset>
                                            <legend>Intrahepatic</legend>
                                            <div>
                                                <div id="divERCPIntrahepatic" runat="server" visible="false" class="inferredDiag"></div>
                                            </div>
                                            <asp:CheckBox ID="D198P2_CheckBox" runat="server" Text="<b>Normal ducts</b>" Font-Bold="true" />
                                            <%-- NormalDuctsCheckBox--%>
                                            <table id="IntrahepaticTable">
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="D210P2_CheckBox" runat="server" Text="Suppurative cholangitis" />
                                                        <%-- SuppurativeCheckBox--%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="4">
                                                        <span style="float: left">
                                                            <asp:CheckBox ID="D220P2_CheckBox" runat="server" Text="Biliary leak" />
                                                            <%-- BiliaryLeakSiteCheckBox--%>
                                                        </span>
                                                        <div id="BiliaryLeakDiv" runat="server" style="display: none; float: left">
                                                            <telerik:RadComboBox ID="BiliaryLeakSiteRadComboBox" runat="server" Skin="Windows7" AllowCustomText="true" Width="150px" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="4">
                                                        <div id="IntrahepaticTumourDiv" runat="server" style="float: left; display: none; border: 1px dotted #B8CBDE; padding: 5px 10px;">
                                                            <div style="border-bottom: 1px dotted #B8CBDE; margin-bottom: 5px;">
                                                                <b>Tumour</b>
                                                            </div>
                                                            <asp:CheckBox ID="D242P2_CheckBox" runat="server" Text="probable" />
                                                            <%-- IntrahepaticTumourProbableCheckBox--%>
                                                                                        &nbsp;&nbsp;&nbsp;
                                                                                        <asp:CheckBox ID="D243P2_CheckBox" runat="server" Text="possible" />
                                                            <%-- IntrahepaticTumourPossibleCheckBox--%>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </td>
                                    </tr>
                                <tr>
                                    <td>
                                        <fieldset>
                                            <legend>Extrahepatic</legend>
                                            <asp:CheckBox ID="D265P2_CheckBox" runat="server" Text="<b>Normal ducts</b>" Font-Bold="true" />
                                            <%-- ExtrahepaticNormalCheckBox--%>
                                            <table id="ExtrahepaticTable">
                                                <tr>
                                                    <td colspan="4">
                                                        <span style="float: left">
                                                            <asp:CheckBox ID="D280P2_CheckBox" runat="server" Text="Biliary leak" />
                                                            <%-- ExtrahepaticLeakSiteCheckBox--%>
                                                        </span>
                                                        <div id="ExtrahepaticLeakDiv" runat="server" style="display: none; float: left">
                                                            <telerik:RadComboBox ID="ExtrahepaticLeakSiteRadComboBox" runat="server" Skin="Windows7" AllowCustomText="true" Width="150px" />
                                                        </div>
                                                    </td>
                                                </tr>

                                                <tr>
                                                    <td colspan="4">
                                                        <span style="float: left; padding-right: 10px">
                                                            <asp:CheckBox ID="D290P2_CheckBox" runat="server" Text="Stricture" />
                                                            <%-- ExtrahepaticTumourCheckBox--%>
                                                        </span>
                                                        <div id="ExtrahepaticTumourDiv" runat="server" style="float: left; display: none">
                                                            <span style="float: left">
                                                                <asp:RadioButtonList runat="server" ID="ExtrahepaticTumourRadioButtonList" RepeatDirection="Horizontal">
                                                                    <asp:ListItem Text="benign" Value="1" />
                                                                    <asp:ListItem Text="malignant" Value="2" />
                                                                </asp:RadioButtonList></span>
                                                            <span style="float: left; padding-top:7px;">
                                                                <asp:CheckBox ID="D325P2_CheckBox" runat="server" Text="(probable)" />
                                                                <%-- ExtrahepaticProbableCheckBox--%>
                                                            </span>
                                                        </div>

                                                    </td>
                                                </tr>
                                                <tr id="BeningTR" runat="server" style="display: none">
                                                    <td colspan="4">
                                                        <fieldset>
                                                            <table style="padding-left: 10px">
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="D305P2_CheckBox" runat="server" Text="pancreatitis" />
                                                                        <%-- BeningPancreatitisCheckBox--%>
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="D310P2_CheckBox" runat="server" Text="a pseudocyst" />
                                                                        <%-- BeningPseudocystCheckBox--%>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="D315P2_CheckBox" runat="server" Text="previous surgery" />
                                                                        <%-- BeningPreviousCheckBox--%>
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="D320P2_CheckBox" runat="server" Text="sclerosing cholangitis" />
                                                                        <%-- BeningSclerosingCheckBox--%>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="D337P2_CheckBox" runat="server" Text="(probable)" />
                                                                        <%-- BeningProbableCheckBox--%>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                                <tr id="MalignantTR" runat="server" style="display: none">
                                                    <td colspan="4">
                                                        <fieldset>
                                                            <table style="padding-left: 10px">
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="D340P2_CheckBox" runat="server" Text="gallbladder carcinoma" />
                                                                        <%-- MalignantGallbladderCheckBox--%>
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="D345P2_CheckBox" runat="server" Text="metastatic carcinoma" />
                                                                        <%-- MalignantMetastaticCheckBox--%>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="D350P2_CheckBox" runat="server" Text="cholangiocarcinoma" />
                                                                        <%-- MalignantCholangiocarcinomaCheckBox--%>
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="D355P2_CheckBox" runat="server" Text="pancreatic carcinoma" />
                                                                        <%-- MalignantPancreaticCheckBox--%>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="D338P2_CheckBox" runat="server" Text="(probable)" />
                                                                        <%-- MalignantProbableCheckBox--%>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
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
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
