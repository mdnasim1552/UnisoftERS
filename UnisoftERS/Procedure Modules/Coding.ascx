<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Coding.ascx.vb" Inherits="UnisoftERS.Coding" %>
<telerik:RadScriptBlock runat="server">
    <style type="text/css">
        /* Style the button that is used to open and close the collapsible content */
        .collapsible {
            cursor: pointer;
        }


        /* Style the collapsible content. Note: hidden by default */
        .collapsible-content {
            display: none;
        }

        .collapsible-instructions {
            font-size: 12px !important;
        }
    </style>
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {
            //$('.coding-cb').on('change', function () {
            //    var codeId = $(this).attr('data-codeid');
            //    var index = $('.coding-cb').index(this);
            //    console.log("index ", index)
            //    console.log("  $(this)", $(this))
            //    var checked = $(this).is(':checked');
            //    console.log("checked  checked", checked)
            //    var isFibre = ($(this).attr('data-codetype') == 'fibre');
            //    var isRigid = ($(this).attr('data-codetype') == 'rigid');
            //    console.log("codeId, isFibre, isRigid", codeId, isFibre, isRigid )
            //    saveCoding(codeId, isFibre, isRigid);
               
            //});

            $('.collapsible').on('click', function () {
                this.classList.toggle("active");
                var content = this.nextElementSibling;
                if (content.style.display === "block") {
                    content.style.display = "none";
                    $(this).find('.collapsible-instructions').text('(click to expand)');
                } else {
                    content.style.display = "block";
                    $(this).find('.collapsible-instructions').text('(click to collapse)');
                }
            });
        });

        /*  function saveCoding(codeId, isFibre, isRigid) {*/
        function saveCoding(codeId, checkboxStatus, checkboxType) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);;
            obj.codeId = codeId;
            obj.checkboxStatus = checkboxStatus;
            obj.checkboxType = checkboxType;

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/SaveBronchoCoding",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

        function checkCheckBoxStatus(checkbox, checkboxType) {
      
            var parentSpan = $(checkbox).closest('.coding-cb');
            var codeId = parentSpan.data('codeid');
            let checkboxStatus = checkbox.checked
            saveCoding(codeId, checkboxStatus, checkboxType);
        }




    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<asp:ObjectDataSource ID="DrugsObjectDataSource" runat="server" SelectMethod="GetBronchoPremedication" TypeName="UnisoftERS.OtherData">
    <SelectParameters>
        <asp:Parameter Name="procedureId" DbType="String" />
    </SelectParameters>
</asp:ObjectDataSource>
<div class="control-section-header abnorHeader">Coding</div>

<div class="control-sub-header collapsible" id="Div1" runat="server">
    <img src="../../Images/icons/expand-button.png" alt="" />Diagnostic endoscopic examination&nbsp;<span class="collapsible-instructions">(click to expand)</span>
</div>
<div class="control-content collapsible-content">

    <asp:Repeater ID="DiagnosisRepeater" runat="server">
        <HeaderTemplate>
            <table cellpadding="3" cellspacing="3">
                <tr>
                    <td></td>
                    <td>Fibre optic</td>
                    <td>Rigid</td>
                </tr>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td width="250px">
                    <asp:Label ID="CodeNameLabel" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                    <asp:HiddenField ID="CodeIdHiddenField" runat="server" Value='<%# Bind("CodeId") %>' />
                </td>
                <td width="200px">
                    <asp:CheckBox ID="FibreOpticCheckBox"  runat="server" data-codeid='<%#Eval("CodeId") %>' data-codetype="fibre" Text='<%# Bind("FibreOpticCode") %>' Checked='<%# Bind("FibreOpticCodeValue") %>' CssClass="coding-cb cb-fibre"   onclick="checkCheckBoxStatus(this, 'Fibre')"/></td>
                </td>
            <td width="200px">
                <asp:CheckBox ID="RigidCheckBox" runat="server" data-codeid='<%#Eval("CodeId") %>' data-codetype="rigid" Text='<%# Bind("RigidCode") %>' Checked='<%# Bind("RigidCodeValue") %>' CssClass="coding-cb cb-rigid"  onclick="checkCheckBoxStatus(this, 'Rigid')"/></td>
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>
</div>

<div class="control-sub-header collapsible" id="Div2" runat="server" style="margin-top: 10px;">
    <img src="../../Images/icons/expand-button.png" alt="" />Therapeutic endoscopic operations&nbsp;<span class="collapsible-instructions">(click to expand)</span>
</div>
<div class="control-content collapsible-content">
    <asp:Repeater ID="TherapeuticRepeater" runat="server">
        <HeaderTemplate>
            <table cellpadding="3" cellspacing="3">
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td width="250px">
                    <asp:Label ID="CodeNameLabel" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                    <asp:HiddenField ID="CodeIdHiddenField" runat="server" Value='<%# Bind("CodeId") %>' />
                </td>
                <td width="200px">
                    <asp:CheckBox ID="FibreOpticCheckBox" runat="server" data-codeid='<%#Eval("CodeId") %>' data-codetype="fibre" Text='<%# Bind("FibreOpticCode") %>' Checked='<%# Bind("FibreOpticCodeValue") %>' CssClass="coding-cb cb-fibre"   onclick="checkCheckBoxStatus(this, 'Fibre')"/></td>
                </td>
            <td width="200px">
                <asp:CheckBox ID="RigidCheckBox" runat="server" data-codeid='<%#Eval("CodeId") %>' data-codetype="rigid" Text='<%# Bind("RigidCode") %>' Checked='<%# Bind("RigidCodeValue") %>' CssClass="coding-cb cb-rigid"  onclick="checkCheckBoxStatus(this, 'Rigid')" /></td>
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>
</div>


<div id="ebusDiv" runat="server">
    <div class="control-sub-header collapsible" id="Div3" runat="server" style="margin-top: 10px;">EBUS lymph node&nbsp;<span class="collapsible-instructions">(click to expand)</span></div>
    <div class="control-content collapsible-content">
        <asp:Repeater ID="EbusRepeater" runat="server">
            <HeaderTemplate>
                <table cellpadding="3" cellspacing="3">
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td width="300px">
                        <asp:Label ID="CodeNameLabel" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                        <asp:HiddenField ID="CodeIdHiddenField" runat="server" Value='<%# Bind("CodeId") %>' />
                    </td>
                    <td width="200px">
                        <asp:CheckBox ID="FibreOpticCheckBox" runat="server" data-codeid='<%#Eval("CodeId") %>' data-codetype="fibre" Text='<%# Bind("FibreOpticCode") %>' Checked='<%# Bind("FibreOpticCodeValue") %>' CssClass="coding-cb cb-fibre"   onclick="checkCheckBoxStatus(this, 'Fibre')"/></td>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>
