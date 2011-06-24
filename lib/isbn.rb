#!/usr/bin/ruby
#
# Copyright (c) 2010, John D. Lewis <balinjdl at gmail.com>, 2011 Stephen Paul Weber <singpolyma.net>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#    * Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

module ISBN
	module_function

	def verify(isbn_in)
		calc_checkDigit(isbn_in[0..isbn_in.length-2]) == isbn_in[isbn_in.length-1,1].to_i
	end

	def calc_checkDigit(isbn_in)
		case isbn_in.length
			when 12
				calc_checkDigit13(isbn_in)
			when 9
				calc_checkDigit10(isbn_in)
		end
	end

	def calc_checkDigit10(isbn_in)
		charPos = 0
		csumTotal = 0
		iarr = isbn_in.split(//)
		for i2 in iarr
			charPos += 1
			csumTotal = csumTotal + (charPos * i2.to_i)
		end
		checkDigit = csumTotal % 11
		if (checkDigit == 10)
			checkDigit = "X"
		end
		checkDigit
	end

	def calc_checkDigit13(isbn_in)
		charPos = 0
		csumTotal = 0
		iarr = isbn_in.split(//)
		for i1 in iarr
			cP2 = charPos/2.to_f

			if (cP2.round == cP2.floor)
				csumTotal = csumTotal + i1.to_i
			else
				csumTotal = csumTotal + (3*i1.to_i)
			end
			charPos += 1
		end
			if (csumTotal == (csumTotal/10.to_i)*10)
				checkDigit = "0"
			else
				checkDigit = 10-(csumTotal - (csumTotal/10.to_i)*10)
			end

			if (checkDigit == 10)
				checkDigit = "X"
			end

			checkDigit
	end

	def fix(isbn)
		return isbn[0,isbn.length-1] + calc_checkDigit(isbn).to_s
	end

	def isbn10_to_isbn13(isbn10)
		s = '978' + isbn10.to_s[0..8]
		s + calc_checkDigit(s).to_s
	end

	def extract(s)
		s.scan(/\d{13}|\d{10}/).map do |isbn|
			# Discard invalid ISBNs
			next nil unless verify(isbn)
			# Convert everything to the new ISBN13s
			isbn = isbn10_to_isbn13(isbn) if isbn.length < 13
			isbn
		end.compact.uniq
	end

end
