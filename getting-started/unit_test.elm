import String
import Graphics.Element exposing (Element)
import ElmTest exposing (..)


tests : Test
tests = suite "My Test Suite"
        [ test "Addition" (assertEqual (3 + 7) 10)
        , test "String.reverse" (assertEqual "ekiM" (String.reverse "Mike"))
        , test "This test should pass" (assert True)
        ]

main : Element
main =
    elementRunner tests
