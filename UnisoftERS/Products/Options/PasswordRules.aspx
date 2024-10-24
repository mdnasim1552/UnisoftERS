<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_PasswordRules" Codebehind="PasswordRules.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {

            });

            $(document).ready(function () {
                $("#PasswordRulesTable input:checkbox").change(function () {
                    var numtxtboxid = $(this)[0].id.replace("CheckBox", "NumericTextBox");
                    if ($find(numtxtboxid)) {
                        if ($(this).is(':checked')) {
                            $find(numtxtboxid).set_value(1);
                        }
                        else {
                            $find(numtxtboxid).set_value();
                        }
                    }
                });

                $("#PasswordRulesTable input:text").change(function () {
                    if ($find($(this)[0].id).get_value() != "") {
                        $(this).closest('tr').find("input:checkbox").prop('checked', true);
                    }
                });
            });
        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <div class="optionsHeading">Password Rules</div>

        <div style="margin-left: 10px;width:833px;" class="optionsHeadingNote">
            <b>Note:</b> Any change of rules will prompt the users to create a new password,  
            the next time they login.
        </div>

        <div id="FormDiv" runat="server" style="margin-left: 10px;margin-top: 30px;width:860px;">
            <fieldset class="sysFieldset">
                <legend><b>Rules to be applied when users create their passwords</b></legend>
                <table id="PasswordRulesTable" runat="server" class="optionsBodyText">
                    <tr style="height: 25px;">
                        <td></td>
                    </tr>
                    <tr style="height: 30px;">
                        <td>
                            <asp:CheckBox ID="MinLengthCheckBox" runat="server" Text="minimum length to be" />
                        </td>
                        <td>
                            <telerik:RadNumericTextBox ID="MinLengthNumericTextBox" runat="server"
                                IncrementSettings-InterceptMouseWheel="false"
                                IncrementSettings-Step="1"
                                Width="35px"
                                MinValue="1">
                                <NumberFormat DecimalDigits="0" />
                            </telerik:RadNumericTextBox>
                            character(s)
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td>
                            <asp:CheckBox ID="NonAlphaCharsCheckBox" runat="server" Text="must contain at least" />
                        </td>
                        <td>
                            <telerik:RadNumericTextBox ID="NonAlphaCharsNumericTextBox" runat="server"
                                IncrementSettings-InterceptMouseWheel="false"
                                IncrementSettings-Step="1"
                                Width="35px"
                                MinValue="1">
                                <NumberFormat DecimalDigits="0" />
                            </telerik:RadNumericTextBox>
                            non-alphanumeric character(s)
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td>
                            <asp:CheckBox ID="NoSpacesCheckBox" runat="server" Text="must NOT include spaces" />
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td>
                            <asp:CheckBox ID="CantBeUserIdCheckBox" runat="server" Text="cannot be the same as the user ID" />
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td>
                            <asp:CheckBox ID="ChangeFrequencyCheckBox" runat="server" Text="must be changed every" />
                        </td>
                        <td>
                            <telerik:RadNumericTextBox ID="ChangeFrequencyNumericTextBox" runat="server"
                                IncrementSettings-InterceptMouseWheel="false"
                                IncrementSettings-Step="1"
                                Width="35px"
                                MinValue="1">
                                <NumberFormat DecimalDigits="0" />
                            </telerik:RadNumericTextBox>
                            day(s)
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td>
                            <asp:CheckBox ID="DifferentToLastPwdsCheckBox" runat="server" Text="must be different to the last" />
                        </td>
                        <td>
                            <telerik:RadNumericTextBox ID="DifferentToLastPwdsNumericTextBox" runat="server"
                                IncrementSettings-InterceptMouseWheel="false"
                                IncrementSettings-Step="1"
                                Width="35px"
                                MinValue="1">
                                <NumberFormat DecimalDigits="0" />
                            </telerik:RadNumericTextBox>
                            password(s)
                        </td>
                    </tr>
                </table>
            </fieldset>
            <div class="divButtons" style="margin-top: 40px;">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton"/>
            </div>
        </div>
    </form>
</body>
</html>
