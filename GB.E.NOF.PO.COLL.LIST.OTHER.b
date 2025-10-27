SUBROUTINE GB.E.NOF.PO.COLL.LIST.OTHER(Y.RETURN)
*=================================================================================================================================
* Developed by       : Nuren Durdana Abha (FDS)
* Description        : Shows data of other branches Collected PO from CHEQUE.REGISTER.SUPPLEMENT application
* RTN Attached in    : APPLICATION: ENQUIRY, ID: GB.ENQ.ONLN.PO.COLL.LST.OTHR
* Routine Type       : Enquiry
* Standard Selection : NOFILE.PO.COLL.OTHER
* Compilation Time   : 26 DEC, 2024 (14:46)
*=================================================================================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING FT.Contract
    $USING TT.Contract
    $USING EB.Reports
    $USING EB.LocalReferences
            
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB MAIN
RETURN
    
INIT:
    FN.CHQ.REG= 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHQ.REG= ''
    
    FN.CHQ.REG.HIS= 'F.CHEQUE.REGISTER.SUPPLEMENT$HIS'
    F.CHQ.REG.HIS= ''
    
    FN.FT.NAU= 'F.FUNDS.TRANSFER$NAU'
    F.FT.NAU= ''
    
    FN.TT.NAU= 'F.TELLER$NAU'
    F.TT.NAU= ''
    
    FN.FT= 'F.FUNDS.TRANSFER'
    F.FT= ''
    
    FN.TT= 'F.TELLER'
    F.TT= ''
    
    FN.FT.HIS= 'F.FUNDS.TRANSFER$HIS'
    F.FT.HIS= ''
    
    FN.TT.HIS= 'F.TELLER$HIS'
    F.TT.HIS= ''
    
    Y.CHQ.ID= ''
    Y.PO.NO= ''
    Y.PAY.TO= ''
    Y.ISS.AMT= ''
    Y.ISS.DT= ''
    Y.DATE.PRESENTED= ''
    Y.ORIGIN= ''
    Y.ORIGIN.REF= ''
    Y.COLL.TXN.REF= ''
    Y.BRANCH= EB.SystemTables.getIdCompany()
    Y.COLL.BR= ''
RETURN
    
OPENFILE:
    EB.DataAccess.Opf(FN.CHQ.REG,F.CHQ.REG)
    EB.DataAccess.Opf(FN.CHQ.REG.HIS,F.CHQ.REG.HIS)
    EB.DataAccess.Opf(FN.FT.NAU,F.FT.NAU)
    EB.DataAccess.Opf(FN.TT.NAU,F.TT.NAU)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.FT.HIS,F.FT.HIS)
    EB.DataAccess.Opf(FN.TT.HIS,F.TT.HIS)
RETURN

MAIN:
    EB.LocalReferences.GetLocRef('CHEQUE.REGISTER.SUPPLEMENT','LT.COLL.TXN.REF', Y.COLL.TXN.REF.POS)
    
    SEL.CMD= 'SELECT ':FN.CHQ.REG:' STATUS EQ CLEARED AND ID.COMP1 EQ PO'
    EB.DataAccess.Readlist(SEL.CMD, SELECT.LIST, '', NO.OF.ITEM, RET.CODE)
    
    LOOP
        REMOVE TRN.ID FROM SELECT.LIST SETTING TXN.POS
    WHILE TRN.ID:TXN.POS
    
        Y.CHQ.ID= TRN.ID
        EB.DataAccess.FRead(FN.CHQ.REG,Y.CHQ.ID,CHQ.REC,F.CHQ.REG,Y.ERR)
        IF CHQ.REC THEN
            Y.COLL.TXN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef,Y.COLL.TXN.REF.POS>
            Y.ORIGIN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsOriginRef>
        END

        GOSUB CHECK.INAU.ENTRY
    REPEAT

    SEL.CMD.HIS= 'SELECT ':FN.CHQ.REG.HIS:' STATUS EQ CLEARED AND ID.COMP1 EQ PO'
    EB.DataAccess.Readlist(SEL.CMD.HIS, SELECT.LIST.HIS, '', NO.OF.ITEM.HIS, RET.CODE.HIS)
    LOOP
        REMOVE TRN.ID FROM SELECT.LIST.HIS SETTING TXN.POS
    WHILE TRN.ID:TXN.POS
    
        Y.HIS.CHQ.ID= TRN.ID

        GOSUB DATA.FETCH.HIS
    REPEAT

RETURN

CHECK.INAU.ENTRY:
    IF Y.COLL.TXN.REF[1,2] EQ 'FT' THEN
        EB.DataAccess.FRead(FN.FT.NAU,Y.COLL.TXN.REF,FT.REC,F.FT.NAU,FT.ERR)
        IF FT.REC EQ '' THEN
            GOSUB DATA.FETCH
        END
    END
    ELSE IF Y.COLL.TXN.REF[1,2] EQ 'TT' THEN
        EB.DataAccess.FRead(FN.TT.NAU,Y.COLL.TXN.REF,TT.REC,F.TT.NAU,TT.ERR)
        IF TT.REC EQ '' THEN
            GOSUB DATA.FETCH
        END
    END
RETURN

DATA.FETCH:
    IF Y.COLL.TXN.REF[1,2] EQ 'FT' THEN
        EB.DataAccess.FRead(FN.FT,Y.COLL.TXN.REF,FT.REC,F.FT,FT.ERR)
        IF FT.REC THEN
            Y.COLL.BR= FT.REC<FT.Contract.FundsTransfer.CoCode>
        END
        ELSE
            GOSUB DATA.FETCH.HIS
        END
    END
    ELSE IF Y.COLL.TXN.REF[1,2] EQ 'TT' THEN
        EB.DataAccess.FRead(FN.TT,Y.COLL.TXN.REF,TT.REC,F.TT,TT.ERR)
        IF TT.REC THEN
            Y.COLL.BR= TT.REC<TT.Contract.Teller.TeCoCode>
        END
        ELSE
            GOSUB DATA.FETCH.HIS
        END
    END
    
    IF Y.BRANCH EQ Y.COLL.BR THEN
        RETURN
    END
    
    EB.DataAccess.FRead(FN.CHQ.REG,Y.CHQ.ID,CHQ.REC,F.CHQ.REG,Y.ERR)
    IF CHQ.REC THEN
        Y.PO.NO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompThr>
        Y.PAY.TO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
        Y.ISS.AMT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
        Y.ISS.DT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIssueDate>
        Y.INPUTTER= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsInputter>
        
        Y.RETURN<-1>= Y.PO.NO:'*':Y.ISS.DT:'*':Y.PAY.TO:'*':Y.COLL.BR:'*':Y.ISS.AMT:'*':Y.ORIGIN.REF:'*':Y.INPUTTER
        !---------------*1*---------*2*-----------*3*----------*4*-----------*5*------------*6*--------------*7*
    END
    
RETURN

DATA.FETCH.HIS:
    IF Y.COLL.TXN.REF[1,2] EQ 'FT' THEN
        EB.DataAccess.FRead(FN.FT.HIS,Y.COLL.TXN.REF:';1',FT.REC,F.FT.HIS,FT.ERR)
        IF FT.REC THEN
            Y.COLL.BR= FT.REC<FT.Contract.FundsTransfer.CoCode>
        END
    END
    ELSE IF Y.COLL.TXN.REF[1,2] EQ 'TT' THEN
        EB.DataAccess.FRead(FN.TT.HIS,Y.COLL.TXN.REF:';1',TT.REC,F.TT.HIS,TT.ERR)
        IF TT.REC THEN
            Y.COLL.BR= TT.REC<TT.Contract.Teller.TeCoCode>
        END
    END
    
    
    IF Y.BRANCH EQ Y.COLL.BR THEN
        RETURN
    END
    
    EB.DataAccess.FRead(FN.CHQ.REG.HIS,Y.HIS.CHQ.ID,CHQ.REC,F.CHQ.REG.HIS,Y.ERR)
    IF CHQ.REC THEN
        Y.PO.NO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompThr>
        Y.PAY.TO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
        Y.ISS.AMT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
        Y.ISS.DT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIssueDate>
        Y.INPUTTER= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsInputter>
        
        Y.RETURN<-1>= Y.PO.NO:'*':Y.ISS.DT:'*':Y.PAY.TO:'*':Y.COLL.BR:'*':Y.ISS.AMT:'*':Y.ORIGIN.REF:'*':Y.INPUTTER
        !---------------*1*---------*2*-----------*3*----------*4*-----------*5*------------*6*--------------*7*
    END
RETURN

END
