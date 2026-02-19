#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
// #include "readbytes.cpp"

#include <vector>
#include <string>
#include <map>
#include <iostream>
#include <sstream>
#include <fstream>
#include <bitset>
#include <iomanip>


int main(int argc, char* argv[]) {
    if (argc < 4) // Checks that at least 3 arguments are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n" << std::endl;
        exit(1);
    }
    //  ./assemble infile1.asm staticmem_outfile.bin instructions_outfile.bin 
    //Prepare output files
    std::ofstream inst_outfile, static_outfile;
    static_outfile.open(argv[argc - 2], std::ios::binary);// maybe error here? argc-2 would be the staticmem_outfile.bin according to above command line arguemnets
    inst_outfile.open(argv[argc - 1], std::ios::binary);
    std::vector<std::string> instructions;

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0F
    */
    std::map<std::string, int> symbol_dict;
    int static_Byte_Counter=0;
    int instruction_Line_Counter=0;
    bool inData = false;
    //For each input file:
    for (int i = 1; i < argc - 2; i++) {
        std::ifstream infile(argv[i]); //  open the input file for reading
        if (!infile) { // if file can't be opened, need to let the user know
            std::cerr << "Error: could not open file: " << argv[i] << std::endl;
            exit(1);
        }
        std::string str;
        while (getline(infile, str)){ //Read a line from the file
            str = clean(str); // remove comments, leading and trailing whitespace
            if (str == "") { //Ignore empty lines
                continue;
            }
            if(str==".data"){
                inData=true;
            }
            if(str==".text"){
                inData=false;
                }
            std::vector<std::string> split_Instruct=split(str,WHITESPACE+",()");
            if (!split_Instruct.empty() && split_Instruct[0].back() == ':'){
                
                std::string label = split_Instruct[0];
                label.pop_back(); 
                if(inData){
                    symbol_dict[label]= static_Byte_Counter;
                    if (split_Instruct.size() > 2 && split_Instruct[1] == ".word") {
                        //i think we can do a static_Byte_Counter += 4 * (split_Instruct.size() - 2)
                        for (int i = 2; i < split_Instruct.size(); i++) {
                            static_Byte_Counter += 4;  // each word = 4 bytes
                        }
                    }
                    else if (split_Instruct.size() > 2 && split_Instruct[1] == ".byte"){
                        static_Byte_Counter += split_Instruct.size() - 2; //so we store each byte as 1 // the -2 is to bypass label and .byte
                    }

                    else if (split_Instruct.size() > 2 && split_Instruct[1] == ".asciiz") {
                        
                        size_t asciiString_start = str.find("\"");
                        size_t asciiString_end = str.find_last_of("\"");

                        if (asciiString_start == std::string::npos || asciiString_end == std::string::npos || asciiString_end <= asciiString_start) {
                            std::cerr << "Error: invalid .asciiz string: " << str << std::endl;
                            exit(1);
                        }

                        asciiString_start += 1; // skip the opening quote
                        std::string asciiString = str.substr(asciiString_start, asciiString_end - asciiString_start);
                        static_Byte_Counter += asciiString.length() + 1; // +1 for null terminator
                    }

                }

                if(!inData){
                    symbol_dict[label]= instruction_Line_Counter;
                }
             }
            if(inData==false && str.find(":") == str.npos){
                // add all diffrent cases, including where >16 bits and adds multiple lines to code, addi is 3
                //La has same issues as beq and bne where we dont know the labels at this point so we can not calculate if it is larger than 16 bits
                // solution is to always expand instructions
                if(split_Instruct[0]=="la"||split_Instruct[0]=="bne"||split_Instruct[0]=="beq"){ //&& Check16Bit(std::stoi(split_Instruct[2])
                    int address = symbol_dict[split_Instruct[2]];
                    instruction_Line_Counter +=2;
                    // if (check16Bit(address)){instruction_Line_Counter ++;}
                    // else{instruction_Line_Counter +=2;}// replaces 1 instructs with 2

                }
                else if(split_Instruct[0]=="addi"){ //updated to match phase if immediate is bigger than 16bit
                    int imm = std::stoi(split_Instruct  [3]); 

                    if (check16Bit(imm)){instruction_Line_Counter ++;}

                    else{instruction_Line_Counter += 3;}// replaces 1 instructs with 3

                }
                else{instruction_Line_Counter++;}
            }
            if(str.find(":") == str.npos){instructions.push_back(str);}
        }
        infile.close();
    }

    /** Phase 2
     * Process all static memory, output to static memory file
     * TODO: All of this
     */
for (int i = 1; i < argc - 2; i++) {
    std::ifstream infile(argv[i]);
    if (!infile) {
        std::cerr << "Error: could not open file: " << argv[i] << std::endl;
        exit(1);
    }

    std::string str;
    bool inData = false;

    while (getline(infile, str)) {

        str = clean(str);
        if (str == "") 
        {continue;}

        if (str == ".data") {
            inData = true;
            continue;
        }
        if (str == ".text") {
            inData = false;
            continue;
        }

        if (!inData) {
            continue;
        }

        std::vector<std::string> split_Instruct =split(str, WHITESPACE + ",()");

        // Skip label only lines
        int startIndex = 0;
        if (str.find(":") != std::string::npos) {
            if (split_Instruct.size() == 1) {continue;}
            startIndex = 1;  //starts after the label
        }

    if (split_Instruct[startIndex] == ".word") {
        for (int j = startIndex + 1; j < split_Instruct.size(); j++) {
            std::string token = split_Instruct[j];
            int value;

            // Check if token is a number
            try {
                value = std::stoi(token);
            } catch (std::invalid_argument&) {
                // Not a number: treat it as a label
                if (symbol_dict.find(token) != symbol_dict.end()) {
                    value = symbol_dict[token];
                } else {
                    std::cerr << "Error: unknown symbol in .word: " << token << std::endl;
                    exit(1);
                }
            }

            write_binary(value, static_outfile);
        }
    }

    }

    infile.close();
}


    /** Phase 3
     * Process all instructions, output to instruction memory file
     * TODO: Almost all of this, it only works for adds
     */
    int max_instruct_line=instructions.size();
    int new_instruction_Line_Counter=0;
    for(std::string inst : instructions) {
        
        std::vector<std::string> terms = split(inst, WHITESPACE+",()");
        std::string inst_type = terms[0];

        if (inst_type == "add") {
            write_binary(encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 32),inst_outfile);
        }
        else if (inst_type == "sub"){
            write_binary(encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 34), inst_outfile);
        }

        else if (inst_type == "addi"){

            int imm = std::stoi(terms[3]);
            if(imm >= -32768 && imm <= 32767){
            write_binary(encode_Itype(8,registers[terms[2]], registers[terms[1]], imm),inst_outfile);}
            else{

                int upper = (imm >> 16) & 0xFFFF;
                int lower = imm & 0xFFFF;

                write_binary(encode_Itype(15,0,1,upper),inst_outfile);
                write_binary(encode_Itype(13,1,1,lower),inst_outfile);
                write_binary(encode_Rtype(0,registers[terms[2]],1, registers[terms[1]], 0, 32),inst_outfile);    
                new_instruction_Line_Counter+=3;
            }
        }

        else if(inst_type == "mult"){
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 24), inst_outfile);
        }

        else if (inst_type == "div"){
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 26),inst_outfile);
        }

        else if (inst_type == "slt") {
            write_binary(encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42),inst_outfile);
        }

        else if (inst_type == "srl") {
            write_binary(encode_Rtype(0,0,registers[terms[2]], registers[terms[1]], registers[terms[3]], 2),inst_outfile);
        }

        else if (inst_type == "sll") {
            write_binary(encode_Rtype(0,0,registers[terms[2]], registers[terms[1]], registers[terms[3]], 0),inst_outfile);
        }

        else if (inst_type == "lw") {
            write_binary(encode_Itype(35,registers[terms[3]],registers[terms[1]],std::stoi(terms[2])),inst_outfile);
        }

        else if (inst_type == "sw") {
            write_binary(encode_Itype(43,registers[terms[3]],registers[terms[1]],std::stoi(terms[2])),inst_outfile);
        }

        else if (inst_type == "mfhi") {
            write_binary(encode_Rtype(0,0,0,registers[terms[1]],0,16),inst_outfile);
        }

        else if (inst_type == "mflo") {       
            write_binary(encode_Rtype(0,0,0,registers[terms[1]],0,18),inst_outfile);
        }

        else if (inst_type == "lui") {
            write_binary(encode_Itype(15,0,registers[terms[1]],std::stoi(terms[2])),inst_outfile);
        }

        else if (inst_type == "ori") {
            write_binary(encode_Itype(13,registers[terms[2]],registers[terms[1]],std::stoi(terms[3])),inst_outfile);
        }
        else if(inst_type=="beq"){
            int val=symbol_dict.at(terms[3])-(new_instruction_Line_Counter+1);
            
                write_binary(encode_Itype(5,registers[terms[1]],registers[terms[2]],1),inst_outfile);
                write_binary(encode_Jtype(2,symbol_dict.at(terms[3])),inst_outfile);
                new_instruction_Line_Counter++;
            
        }

        else if (inst_type == "bne"){
            int val = symbol_dict.at(terms[3]) -(new_instruction_Line_Counter+1);
            
                write_binary(encode_Itype(4, registers[terms[1]], registers[terms[2]],1), inst_outfile);
                write_binary(encode_Jtype(2, symbol_dict.at(terms[3])), inst_outfile);
                new_instruction_Line_Counter++;
            
        }

        else if(inst_type == "j"){
            write_binary(encode_Jtype(2, symbol_dict.at(terms[1])), inst_outfile);
        }

        else if (inst_type == "jal"){
            write_binary(encode_Jtype(3, symbol_dict.at(terms[1])), inst_outfile);
        }

        else if (inst_type == "jr"){
            write_binary(encode_Rtype(0, registers[terms[1]], 0,0,0, 8), inst_outfile);
        }

        else if (inst_type == "jalr"){
            if (terms.size() > 3){
                write_binary(encode_Rtype(0,registers[terms[2]], 0, registers[terms[1]],0, 9), inst_outfile);
            }
            else{
               write_binary(encode_Rtype(0,registers[terms[1]], 0, 31,0, 9), inst_outfile);
            }
        }

        else if (inst_type == "syscall"){
            write_binary(53260, inst_outfile);
        }

        else if (inst_type == "la"){
            int address = symbol_dict[terms[2]];

                int top = (address >> 16) & 0xFFFF;
                int bot = (address) & 0xFFFF ;

                write_binary(encode_Itype(15,0,registers[terms[1]],top),inst_outfile); //perform a lui operation with top 16
                write_binary(encode_Itype(13,registers[terms[1]],registers[terms[1]],bot),inst_outfile); //perform an ori operation with bottom 16
                new_instruction_Line_Counter++;
            
        }
        new_instruction_Line_Counter++;
    }
    // Unccoment below to run readbytes
    // inst_outfile.close();
    // static_outfile.close();  
    //     std::string filename = argv[argc-1];
    // int buffer;
    // std::ifstream file(filename, std::ios::in | std::ios::binary);
    // while(file.read((char*) &buffer,sizeof(int))) {
    //     std::cout << std::bitset<32>(buffer) << " " << std::setfill('0') <<
    //     std::setw(8) << std::hex << buffer << " " << std::dec << buffer << std::endl;
    // }
    // file.close();
}




#endif
