#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
#include <vector>
#include <string>
#include <map>
#include <iostream>
#include <sstream>
#include <fstream>

int main(int argc, char* argv[]) {
    if (argc < 4) // Checks that at least 3 arguments are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n" << std::endl;
        exit(1);
    }
    //Prepare output files
    std::ofstream inst_outfile, static_outfile;
    static_outfile.open(argv[argc - 1], std::ios::binary);
    inst_outfile.open(argv[argc - 1], std::ios::binary);
    std::vector<std::string> instructions;

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0
    */
    std::map<std::string, int> symbol_dict;
    int static_Byte_Counter=0;
    int instruction_Line_Counter=0;
    bool inData;
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
            if (str.find(":") != str.npos){
                
                std::string label = split_Instruct[0];
                label.pop_back(); 
                if(inData){

                    symbol_dict[label]= static_Byte_Counter;
                    if (split_Instruct.size() > 2 && split_Instruct[1] == ".word") {
                        for (int i = 2; i < split_Instruct.size(); i++) {
                            static_Byte_Counter += 4;  // each word = 4 bytes
                        }
                    }
                }

                if(!inData){
                    symbol_dict[label]= instruction_Line_Counter;
                }
            }

            if (inData == false && str.find(":") == str.npos ){
                if (split_Instruct[0] == "la" ){
                    instruction_Line_Counter ++;
                }
                instruction_Line_Counter ++;
            }
            
            if (str.find(":") == str.npos) {instructions.push_back(str);} // TODO This will need to change for labels
        }
        infile.close();
    }

    /** Phase 2
     * Process all static memory, output to static memory file
     * TODO: All of this
     */

    /** Phase 3
     * Process all instructions, output to instruction memory file
     * TODO: Almost all of this, it only works for adds
     */
    int new_instruction_Line_Counter = 0;
    int max_ins_Line = instructions.size();
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
            int address = std::stoi(terms[3]);
            if (check16bits(address)){
                write_binary(encode_Itype(8,registers[terms[2]], registers[terms[1]], std::stoi(terms[3])),inst_outfile);}

            else{
                uint16_t top = (address >> 16) & 0xFFFF;
                uint16_t bot = (address) & 0xFFFF ;
                write_binary(encode_Itype(15,0,1,top),inst_outfile); //perform a lui operation with top 16
                write_binary(encode_Itype(13,1,1,bot),inst_outfile); //perform an ori operation with bottom 16
                write_binary(encode_Rtype(0,registers[terms[2]], 1, registers[terms[1]], 0, 32),inst_outfile);
                new_instruction_Line_Counter += 2;
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

        else if (inst_type == "beq"){
            int val = symbol_dict.at(terms[3]) -(instruction_Line_Counter+1);
            if (check16bits(val)){
                write_binary(encode_Itype(4,registers[terms[1]], registers[terms[2]], val),inst_outfile);}

            else{
                write_binary(encode_Itype(5, registers[terms[1]], registers[terms[2]],1), inst_outfile);
                write_binary(encode_Jtype(2, symbol_dict.at(terms[3])), inst_outfile);
                new_instruction_Line_Counter++;
            }
        }

        else if (inst_type == "bne"){
            int val = symbol_dict.at(terms[3]) -(instruction_Line_Counter+1);
            if (check16bits(val)){
                write_binary(encode_Itype(5,registers[terms[1]], registers[terms[2]], val),inst_outfile);}

            else{
                write_binary(encode_Itype(4, registers[terms[1]], registers[terms[2]],1), inst_outfile);
                write_binary(encode_Jtype(2, symbol_dict.at(terms[3])), inst_outfile);
                new_instruction_Line_Counter++;
            }        }

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

            if (address >= 0 && address <= 65535){
                write_binary(encode_Itype(13,0,registers[terms[1]],address),inst_outfile);
            }
            else{
                uint16_t top = (address >> 16) & 0xFFFF;
                int16_t bot = (address) & 0xFFFF ;

                write_binary(encode_Itype(15,0,registers[terms[1]],top),inst_outfile); //perform a lui operation with top 16
                write_binary(encode_Itype(13,registers[terms[1]],registers[terms[1]],bot),inst_outfile); //perform an ori operation with bottom 16
                new_instruction_Line_Counter++;
            }
        }
        new_instruction_Line_Counter++;
    }
}




int encode_Rtype(int opcode, int rs, int rt, int rd, int shftamt, int funccode) {
    return (opcode << 26) + (rs << 21) + (rt << 16) + (rd << 11) + (shftamt << 6) + funccode;
}

int encode_Itype(int opcode, int rs, int rt, int immediate){
    return (opcode << 26) + (rs << 21) + (rt << 16) + immediate;
}

int encode_Jtype(int opcode, int address){
    return (opcode << 26) + address;
}
#endif

