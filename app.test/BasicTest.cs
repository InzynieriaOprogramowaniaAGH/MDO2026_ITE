public class BasicTests {
    [Xunit.Fact]
    public void TrueIsTrue() {
        Xunit.Assert.True(true);
    }
    [Xunit.Fact]
    public void AdditionWorks() {
        Xunit.Assert.Equal(4, 2 + 2);
    }
}