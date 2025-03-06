pragma solidity ^0.5.1;

contract Agent {
    
    struct patient {
        string name;
        string email;
        string nationalId;  // National ID/SSN for unique identification
        uint age;
        address[] doctorAccessList;
        uint[] diagnosis;
        string record;
        bool isRegistered;
    }
    
    struct doctor {
        string name;
        string email;
        string licenseNumber;  // Medical license number for unique identification
        uint age;
        address[] patientAccessList;
        bool isRegistered;
    }

    uint creditPool;

    address[] public patientList;
    address[] public doctorList;

    mapping (address => patient) patientInfo;
    mapping (address => doctor) doctorInfo;
    mapping (address => address) Empty;
    mapping (string => bool) usedEmails;
    mapping (string => bool) usedNationalIds;
    mapping (string => bool) usedLicenseNumbers;

    function add_agent(
        string memory _name, 
        string memory _email, 
        string memory _uniqueId,  // National ID for patients, License number for doctors
        uint _age, 
        uint _designation, 
        string memory _hash
    ) public returns(string memory) {
        address addr = msg.sender;
        
        require(!usedEmails[_email], "Email already registered");
        
        if(_designation == 0){  // Patient
            require(!usedNationalIds[_uniqueId], "National ID already registered");
            require(!patientInfo[addr].isRegistered, "Address already registered as patient");
            
            patient memory p;
            p.name = _name;
            p.email = _email;
            p.nationalId = _uniqueId;
            p.age = _age;
            p.record = _hash;
            p.isRegistered = true;
            
            patientInfo[msg.sender] = p;
            patientList.push(addr)-1;
            
            usedEmails[_email] = true;
            usedNationalIds[_uniqueId] = true;
            return _name;
        }
        else if (_designation == 1){  // Doctor
            require(!usedLicenseNumbers[_uniqueId], "License number already registered");
            require(!doctorInfo[addr].isRegistered, "Address already registered as doctor");
            
            doctor memory d;
            d.name = _name;
            d.email = _email;
            d.licenseNumber = _uniqueId;
            d.age = _age;
            d.isRegistered = true;
            
            doctorInfo[addr] = d;
            doctorList.push(addr)-1;
            
            usedEmails[_email] = true;
            usedLicenseNumbers[_uniqueId] = true;
            return _name;
        }
        else {
            revert("Invalid designation");
        }
    }

    // Updated getter functions to include new fields
    function get_patient(address addr) view public returns (
        string memory name,
        string memory email,
        string memory nationalId,
        uint age,
        uint[] memory diagnosis,
        address emptyAddr,
        string memory record
    ) {
        require(patientInfo[addr].isRegistered, "Patient not registered");
        return (
            patientInfo[addr].name,
            patientInfo[addr].email,
            patientInfo[addr].nationalId,
            patientInfo[addr].age,
            patientInfo[addr].diagnosis,
            Empty[addr],
            patientInfo[addr].record
        );
    }

    function get_doctor(address addr) view public returns (
        string memory name,
        string memory email,
        string memory licenseNumber,
        uint age
    ) {
        require(doctorInfo[addr].isRegistered, "Doctor not registered");
        return (
            doctorInfo[addr].name,
            doctorInfo[addr].email,
            doctorInfo[addr].licenseNumber,
            doctorInfo[addr].age
        );
    }



    function permit_access(address addr) payable public {
        require(msg.value == 2 ether);

        creditPool += 2;
        
        doctorInfo[addr].patientAccessList.push(msg.sender)-1;
        patientInfo[msg.sender].doctorAccessList.push(addr)-1;
        
    }


    //must be called by doctor
    function insurance_claim(address paddr, uint _diagnosis, string memory  _hash) public {
        bool patientFound = false;
        for(uint i = 0;i<doctorInfo[msg.sender].patientAccessList.length;i++){
            if(doctorInfo[msg.sender].patientAccessList[i]==paddr){
                msg.sender.transfer(2 ether);
                creditPool -= 2;
                patientFound = true;
                
            }
            
        }
        if(patientFound==true){
            set_hash(paddr, _hash);
            remove_patient(paddr, msg.sender);
        }else {
            revert();
        }

        bool DiagnosisFound = false;
        for(uint j = 0; j < patientInfo[paddr].diagnosis.length;j++){
            if(patientInfo[paddr].diagnosis[j] == _diagnosis)DiagnosisFound = true;
        }
    }

    function remove_element_in_array(address[] storage Array, address addr) internal returns(uint)
    {
        bool check = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++){
            if(Array[i] == addr){
                check = true;
                del_index = i;
            }
        }
        if(!check) revert();
        else{
            if(Array.length == 1){
                delete Array[del_index];
            }
            else {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];

            }
            Array.length--;
        }
    }

    function remove_patient(address paddr, address daddr) public {
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);
    }
    
    function get_accessed_doctorlist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage doctoraddr = patientInfo[addr].doctorAccessList;
        return doctoraddr;
    }
    function get_accessed_patientlist_for_doctor(address addr) public view returns (address[] memory )
    {
        return doctorInfo[addr].patientAccessList;
    }

    
    function revoke_access(address daddr) public payable{
        remove_patient(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }

    function get_patient_list() public view returns(address[] memory ){
        return patientList;
    }

    function get_doctor_list() public view returns(address[] memory ){
        return doctorList;
    }

    function get_hash(address paddr) public view returns(string memory ){
        return patientInfo[paddr].record;
    }

    function set_hash(address paddr, string memory _hash) internal {
        patientInfo[paddr].record = _hash;
    }

}

