<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Ebus.ascx.vb" Inherits="UnisoftERS.Ebus" %>

<%@ Register TagPrefix="PreProc" TagName="Indications" Src="~/Procedure Modules/Indications.ascx" %>
<%@ Register TagPrefix="PreProc" TagName="CoMorbidity" Src="~/Procedure Modules/CoMorbidity.ascx" %>
<%@ Register TagPrefix="PreProc" TagName="Allergies" Src="~/Procedure Modules/Allergies.ascx" %>
<%@ Register TagPrefix="PreProc" TagName="Referral" Src="~/Procedure Modules/ReferralData.ascx" %>
<%@ Register TagPrefix="PreProc" TagName="DrugsAdministered" Src="~/Procedure Modules/DrugsAdministered.ascx" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        $(window).on('load', function () {

        });

        $(document).ready(function () {
           
        });

        
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />

<asp:ObjectDataSource ID="ConsultantDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetBronchoPremedication">
    <SelectParameters>
        <asp:Parameter Name="consultantType" DbType="String" DefaultValue="1" />
    </SelectParameters>
</asp:ObjectDataSource>

<div class="procedure-control">
    <div class="control-section-header abnorHeader">Indications&nbsp;<img src="../Images/NEDJAG/Ned.png" alt="NED Mandatory Field" /></div>
    <PreProc:Indications ID="PreProcIndications" runat="server" />
</div>
<div class="procedure-control">
    <div class="control-section-header abnorHeader">Comorbidity&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
    <PreProc:CoMorbidity ID="PreProcCoMorbidity" runat="server" />
</div>
<div class="procedure-control">
    <div class="control-section-header abnorHeader">Allergies&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
    <PreProc:Allergies ID="PreProcAllergies" runat="server" />
</div>
<div class="procedure-control">
    <div class="control-section-header abnorHeader">Referral Data&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
    <PreProc:Referral ID="PreProcReferral" runat="server" />
</div>
<div class="procedure-control">
    <div class="control-section-header abnorHeader">Drugs&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
    <PreProc:DrugsAdministered ID="PreProcDrugsAdministered" runat="server" />
</div>



