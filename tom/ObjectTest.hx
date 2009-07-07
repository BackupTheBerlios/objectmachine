
/*

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
    // Test the 'text' script command which starts a text string.
    // ### ends the string.
    //
    // Examples:
    //  'text This is some text ###' represents the string "This is some text"
    //  'text  This is some text  ###' represents the string " This is some text "
    //  (note the two spaces at the beginning and the end of the text)
    
    public function testString1()
    {
        var object : Object = new Object();
        
        var string = "This is some text";
        object.execute( "text " + string + " ###");
        var res = object.pop();
        
        this.assertEquals(string, res);
    }

    public function testString2()
    {
        var object : Object = new Object();

        var string = " This is some text ";
        object.execute( "text " + string + " ###");
        var res = object.pop();
        
        this.assertEquals(string, res);
    }

    public function testString3()
    {
        var object : Object = new Object();

        var string = " This is some text " + '"' + "with quotes" + '"';
        object.execute( "text " + string + " ###");
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
    
    public function testMessageBreak()
    {
        // The word 'message' should halt the interpretation of the script.
        // This is done to be more efficient in delivering messages and
        // to prevent side-effects from words in the message itself.
        
        var object : Object = new Object();
        
        object.execute( "1 2 message 3 4");
        
        this.assertEquals("2", object.pop());
        this.assertEquals("1", object.pop());
    }
    
    public function testName()
    {
        // Each object can have a name set by a ascript.
        
        var object : Object = new Object();
        
        object.execute( "abcd name");
        object.execute( "getname");
        
        this.assertEquals( "abcd", object.pop());
    }
    
    public function testExtractMessage()
    {
        // This is not used directly in scripts but I need to be able to
        // test the message extraction function somehow.
        // Given a message like this 'aaa aaa message bbb bbb message cc cc'
        // I should receive 'bbb bbb message cc cc'.
        // The special word testExtractMessage will return the extracted
        // message as a string on the object stack.
        
        var object : Object = new Object();
        
        object.execute( "text aaa aaa message bbb bbb message cc cc ### testExtractMessage");
        
        this.assertEquals( "bbb bbb message cc cc", object.pop());
    }
    
}
