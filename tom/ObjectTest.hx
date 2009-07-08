
/**

Copyright 2009 The Object Machine Project. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE OBJECT MACHINE PROJECT ``AS IS'' AND ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE OBJECT MACHINE PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

The views and conclusions contained in the software and documentation are those of
the authors and should not be interpreted as representing official policies, either
expressed or implied, of The Object Machine Project.

*/

/*

Unit tests for the tom.Object class.

*/

package tom;

class ObjectTest extends haxe.unit.TestCase
{
    // Test the " script command which starts a text string.
    // " ends the string.
    //
    // Examples:
    //  '" This is some text "' represents the string "This is some text"
    //  '"  This is some text  "' represents the string " This is some text "
    //  (note the two spaces at the beginning and the end of the text)
    
    public function testString1()
    {
        var object : Object = new Object();
        
        var string = "This is some text";
        object.execute( '" ' + string + ' "');
        var res = object.pop();
        
        this.assertEquals(string, res);
    }

    public function testString2()
    {
        var object : Object = new Object();

        var string = " This is some text ";
        object.execute( '" ' + string + ' "');
        var res = object.pop();
        
        this.assertEquals(string, res);
    }

    public function testString3()
    {
        var object : Object = new Object();

        var string = 'This is some text "with quotes"';
        object.execute( '" ' + string + ' "');
        var res = object.pop();
        
        this.assertEquals(string, res);
    }
    
    public function testUnknown()
    {
        // Check that unknonwn words are actually put on the stack as strings
        
        var object : Object = new Object();

        object.execute( "abc def ghi");
        
        this.assertEquals( "ghi", object.pop());
        this.assertEquals( "def", object.pop());
        this.assertEquals( "abc", object.pop());
    }
    
    public function testName()
    {
        // Each object can have a name set by a ascript.
        
        var object : Object = new Object();
        
        object.execute( "abcd name");
        object.execute( "getname");
        
        this.assertEquals( "abcd", object.pop());
    }
}
