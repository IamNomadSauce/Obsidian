
<map version="0.9.0">
    <node TEXT="NETWORK+" FOLDED="false" POSITION="right" ID="5d8cd66a1730ee3c1c3f393e" X_COGGLE_POSX="639" X_COGGLE_POSY="-342">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="17"/>
        <node TEXT="ETHERNET" FOLDED="false" POSITION="right" ID="40bf2996f0b413dbd4b36bc5">
            <edge COLOR="#e23e2b"/>
            <font NAME="Helvetica" SIZE="34"/>
            <node TEXT="ETHERNET FRAME" FOLDED="false" POSITION="right" ID="5c7e4a387930c7234899f275">
                <edge COLOR="#e23e2b"/>
                <font NAME="Helvetica" SIZE="24"/>
                <node TEXT="PREAMBLE" FOLDED="false" POSITION="right" ID="4bb999b35cd098648322a685">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="7 Bytes" FOLDED="false" POSITION="right" ID="40c6043db5e89b53d704c669">
                        <edge COLOR="#e23e2e"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="56 Alternating 1's and 0's - 
1010101010101... 
used for synchronization
" FOLDED="false" POSITION="right" ID="a6ffedbcc46126201bff93cb">
                        <edge COLOR="#e53726"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="SFD" FOLDED="false" POSITION="right" ID="554bc30fd1a87336e2d2d65e">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="1 byte" FOLDED="false" POSITION="right" ID="d16989b79982534337c3d0d8">
                        <edge COLOR="#e33322"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Start Frame Delimiter - Designates end of preamble" FOLDED="false" POSITION="right" ID="19104c09280f77e34bad9b62">
                        <edge COLOR="#e54434"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="DEST MAC" FOLDED="false" POSITION="right" ID="0be845ce841ad1f6b47d32bd">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="6 bytes" FOLDED="false" POSITION="right" ID="69070454139a93b5bcd68cc1">
                        <edge COLOR="#e33a2a"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT=" ![Ethernet_Frame](attached://f3c78f6b9f56f6b744e64f4df1b333cc 1084x329) " FOLDED="false" POSITION="right" ID="1a7378a8daa565d4e7e5dc15">
                    <edge COLOR="#e03727"/>
                    <font NAME="Helvetica" SIZE="50"/>
                </node>
                <node TEXT="SOURCE MAC" FOLDED="false" POSITION="right" ID="972a7bb90d998e757429cb33">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="6 bytes" FOLDED="false" POSITION="right" ID="825fda00cc3c751886c30265">
                        <edge COLOR="#e24637"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="ETHER TYPE" FOLDED="false" POSITION="right" ID="3a25a41a98c9341fe9615ecd">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="2 bytes" FOLDED="false" POSITION="right" ID="1948334e4ff521b2d5f59db9">
                        <edge COLOR="#e43d2d"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Describes data contained in payload" FOLDED="false" POSITION="right" ID="c6d7ccac1be10f7679411c36">
                        <edge COLOR="#df3828"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="PAYLOAD" FOLDED="false" POSITION="right" ID="b4ca81f0181e8f61537a24b4">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="46-1500 bytes" FOLDED="false" POSITION="right" ID="a3f716dd1219c2b5e2668190">
                        <edge COLOR="#e03525"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Layer 3 and higher data" FOLDED="false" POSITION="right" ID="4fa63444788d091181f355d9">
                        <edge COLOR="#e03d2d"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="FCS" FOLDED="false" POSITION="right" ID="7b81b3235b76b35c57387e5b">
                    <edge COLOR="#e23e2b"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="4 bytes" FOLDED="false" POSITION="right" ID="5b14357276e95addae61288d">
                        <edge COLOR="#e03929"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Frame Check Sequence - CRC checksum of the frame" FOLDED="false" POSITION="right" ID="067dbbfb6433855a9f209acd">
                        <edge COLOR="#e14536"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
            </node>
            <node TEXT="STANDARDS" FOLDED="false" POSITION="right" ID="b1819ba00fcd4d7e15c67ee1">
                <edge COLOR="#e03221"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Ethernet" FOLDED="false" POSITION="right" ID="1ae5d13fad2a49279c8ec8f7">
                    <edge COLOR="#dd2c1e"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="10BaseFL" FOLDED="false" POSITION="right" ID="f92c996a078637ac2d61da56">
                        <edge COLOR="#e02a1e"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="10Mbps (full duplex)" FOLDED="false" POSITION="right" ID="90047bfab10fb0fed86cb551">
                            <edge COLOR="#da251c"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                        <node TEXT="Fiber Optic" FOLDED="false" POSITION="right" ID="b39ace85047199568f846e97">
                            <edge COLOR="#df261d"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                    </node>
                </node>
                <node TEXT="Fast Ethernet" FOLDED="false" POSITION="right" ID="cccd88cb8e28b742b1162715">
                    <edge COLOR="#e12e20"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="100BaseTX" FOLDED="false" POSITION="right" ID="82e6a0a168da2cb8be8d4c1d">
                        <edge COLOR="#dd271c"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="100Mbps (half-duplex)" FOLDED="false" POSITION="right" ID="f82a8ba1960394fc5960bcc6">
                            <edge COLOR="#e42d24"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                        <node TEXT="200Mbps (full-duplex)" FOLDED="false" POSITION="right" ID="e43b5785d0c41d984c2c2bd0">
                            <edge COLOR="#da271f"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                    </node>
                </node>
                <node TEXT="Gigabit Ethernet" FOLDED="false" POSITION="right" ID="8291989d7673d83879945629">
                    <edge COLOR="#da2e21"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="1000BaseCX" FOLDED="false" POSITION="right" ID="6a9b37d508b5afd5feea19b1">
                        <edge COLOR="#dc352b"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="1000BaseSX" FOLDED="false" POSITION="right" ID="93e2147f77d8e519fd57dd90">
                        <edge COLOR="#d2281f"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="1000BaseLX" FOLDED="false" POSITION="right" ID="c040a01f22e4846302ff1606">
                        <edge COLOR="#d02b21"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="10 Gigabit Ethernet" FOLDED="false" POSITION="right" ID="9a026db3976d97f4edd24d6d">
                    <edge COLOR="#e22d1f"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="10GBaseLR" FOLDED="false" POSITION="right" ID="e6e27668446415bef72d8a33">
                        <edge COLOR="#df251a"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
            </node>
        </node>
        <node TEXT="" FOLDED="false" POSITION="right" ID="0b2f235e03e1305a6fcd38f3" X_COGGLE_JOINEDTO="f7518d314b5cc0fbc8fe7971">
            <edge COLOR="#efa670"/>
            <font NAME="Helvetica" SIZE="15"/>
        </node>
    </node>
    <x-coggle-rootnode TEXT="NIEE" FOLDED="false" POSITION="right" ID="3d3d7695c6d7fc9e153b0b01" X_COGGLE_POSX="-990" X_COGGLE_POSY="-3513">
        <edge COLOR="#a1d46e"/>
        <font NAME="Helvetica" SIZE="13"/>
        <node TEXT=" ![Screen Shot 2019-09-26 at 3.36.16 PM](attached://0e74d90958dc6e2750b3711407ba3386 545x269) " FOLDED="false" POSITION="right" ID="3b919d5dcae25d383a6fdcee">
            <edge COLOR="#a2d26e"/>
            <font NAME="Helvetica" SIZE="13"/>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT=" ![Screen Shot 2019-09-26 at 3.29.47 PM](attached://4da779de6b149336a128b6163562a26f 300x157) " FOLDED="false" POSITION="right" ID="c572c6d5765f916840ef9a29" X_COGGLE_POSX="-2086" X_COGGLE_POSY="-2805">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="50"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT=" ![Screen Shot 2019-09-26 at 3.27.56 PM](attached://418e24f3ba117e332fc9cd87af74a6d5 260x300) " FOLDED="false" POSITION="right" ID="d775ec79d19341c0fbc36e38" X_COGGLE_POSX="-1563" X_COGGLE_POSY="-2679">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="50"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT=" ![Screen Shot 2019-09-26 at 4.17.10 PM](attached://980fa24a200dfb141cf3f930c6364289 172x343) " FOLDED="false" POSITION="right" ID="e2a5d4e4014ccd697078113a" X_COGGLE_POSX="-2980" X_COGGLE_POSY="-1783">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="50"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT=" ![Screen Shot 2019-09-25 at 8.10.00 PM](attached://f1cb0b9145cafd87bf806dcc87091f6c 583x441) " FOLDED="false" POSITION="right" ID="6b16d6db2faed0d8a022f2b0" X_COGGLE_POSX="4218" X_COGGLE_POSY="-1591">
        <edge COLOR="#a0d468"/>
        <font NAME="Helvetica" SIZE="12"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="NETWORK MODELS :" FOLDED="false" POSITION="right" ID="8c2bb7e6831748325aa49e8c" X_COGGLE_POSX="2310" X_COGGLE_POSY="-1526">
        <edge COLOR="#0a660d"/>
        <font NAME="Helvetica" SIZE="29"/>
        <node TEXT="Topologies" FOLDED="false" POSITION="right" ID="07092463d37c022299168f8c">
            <edge COLOR="#0a660d"/>
            <font NAME="Helvetica" SIZE="49"/>
            <node TEXT="RING" FOLDED="false" POSITION="right" ID="c0e4f8c00ec5082d7fc4a3be">
                <edge COLOR="#0a660a"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT=" ![Screen Shot 2019-09-26 at 12.31.01 PM](attached://2abfddb07aee2eccfa86f3ba0b680e26 300x294) " FOLDED="false" POSITION="right" ID="18d08ca47edfbbda216fa1f4">
                    <edge COLOR="#0a5d09"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="MESH" FOLDED="false" POSITION="right" ID="d1bf7c8df6a956a32089b5b8">
                <edge COLOR="#0b7b0c"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT=" ![Screen Shot 2019-09-26 at 12.30.57 PM](attached://16fc4455ae83b1aaf03895a2aca4cf32 251x300) " FOLDED="false" POSITION="right" ID="b0bc758dfc91769e13d9cdb2">
                    <edge COLOR="#0a7b09"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="The way a network is physically wired" FOLDED="false" POSITION="right" ID="f03159435e53e75ec2bab290">
                <edge COLOR="#0a660b"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="STAR" FOLDED="false" POSITION="right" ID="f206bb010fb95a6f4c02192c">
                <edge COLOR="#0a6c0b"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT=" ![Screen Shot 2019-09-26 at 12.31.11 PM](attached://190a8043b12177aa4c20a9c74a43f803 293x300) " FOLDED="false" POSITION="right" ID="9afa034edec7af6bd178e56b">
                    <edge COLOR="#0b710b"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="BUS" FOLDED="false" POSITION="right" ID="ae3f59d77cccb15ec665ec03">
                <edge COLOR="#0b6f0b"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT=" ![Screen Shot 2019-09-26 at 12.30.53 PM](attached://3de5bf1a93900d83b038367681d859ae 300x207) " FOLDED="false" POSITION="right" ID="25d0261bf3ce9b3e3e1fb295">
                    <edge COLOR="#0c740a"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
        </node>
        <node TEXT="OSI MODEL" FOLDED="false" POSITION="right" ID="c2b13bb47c721881c5d26fd1">
            <edge COLOR="#0a660d"/>
            <font NAME="Helvetica" SIZE="30"/>
            <node TEXT="1: PHYSICAL" FOLDED="false" POSITION="right" ID="113fd449888abe9881422a56">
                <edge COLOR="#a8d676"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="Signaling, cabling, connectors" FOLDED="false" POSITION="right" ID="0d18b4b53675d1284db2dded">
                    <edge COLOR="#aeda7a"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Not about protocols" FOLDED="false" POSITION="right" ID="603a74559ee54915cef1fa72">
                    <edge COLOR="#a9d872"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="2: DATA LINK" FOLDED="false" POSITION="right" ID="c602b4507c480ea757ed7bf8">
                <edge COLOR="#a7d872"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="Basic network language" FOLDED="false" POSITION="right" ID="cc250de26531d7ed836343ca">
                    <edge COLOR="#a3d569"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="MAC address on Ethernet" FOLDED="false" POSITION="right" ID="ed010192536d6dc07553462d">
                    <edge COLOR="#a6d76d"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="3: NETWORK" FOLDED="false" POSITION="right" ID="578f476e0aa680264a735bf9">
                <edge COLOR="#a9d678"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="Routing" FOLDED="false" POSITION="right" ID="d3a7863712ff713aaa13baff">
                    <edge COLOR="#a5d46e"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="IP" FOLDED="false" POSITION="right" ID="c4b71b082bf9ec0dde519008">
                    <edge COLOR="#abd57b"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Fragments frames to traverse different networks" FOLDED="false" POSITION="right" ID="2e9f0a22727c699b37b911d9">
                    <edge COLOR="#a9d773"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="4: TRANSPORT" FOLDED="false" POSITION="right" ID="d7e061e7f9c8e6b3e61fdb71">
                <edge COLOR="#acd97d"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="Segmentation/Reassembly" FOLDED="false" POSITION="right" ID="8272033b531c2298eaacaa8f">
                    <edge COLOR="#b0db81"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Assigns Port Numbers" FOLDED="false" POSITION="right" ID="bff37a369bc42073d8dfc524">
                    <edge COLOR="#abd67c"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="TCP/UDP" FOLDED="false" POSITION="right" ID="cde549fb8cfe98251f1c560c">
                    <edge COLOR="#adda7a"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="5: SESSION" FOLDED="false" POSITION="right" ID="d02bb28cf01d0e7241d49836">
                <edge COLOR="#a6d474"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="Session Tracking/Renaming" FOLDED="false" POSITION="right" ID="ddf5bf2162ae4c981b2eef17">
                    <edge COLOR="#a6d173"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="6: PRESENTATION" FOLDED="false" POSITION="right" ID="4f8cb75c6bc843a5d58ff734">
                <edge COLOR="#a4d66e"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="Formatting/Data Conversion" FOLDED="false" POSITION="right" ID="f13de549563d9821ff3cfa87">
                    <edge COLOR="#a5d76b"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Encryption/Decryption" FOLDED="false" POSITION="right" ID="7efcfbee09b671b77bd1abc7">
                    <edge COLOR="#a6d66e"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Data Compression" FOLDED="false" POSITION="right" ID="52f2826caf90ffe5bf6201db">
                    <edge COLOR="#a9d676"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="SSL" FOLDED="false" POSITION="right" ID="86b50790dd67b01148258d9a">
                    <edge COLOR="#a1d367"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="7: APPLICATION" FOLDED="false" POSITION="right" ID="b6b7e6fea759cd8ad4fc116f">
                <edge COLOR="#acda7a"/>
                <font NAME="Helvetica" SIZE="12"/>
                <node TEXT="HTTP/FTP/SMTP" FOLDED="false" POSITION="right" ID="d1adc0407f56c4c8d8440f96">
                    <edge COLOR="#aad775"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
        </node>
        <node TEXT="TCP/IP Model" FOLDED="false" POSITION="right" ID="e3d0d2f2ad197641258e7609">
            <edge COLOR="#0a660d"/>
            <font NAME="Helvetica" SIZE="30"/>
            <node TEXT=" ![Screen Shot 2019-09-25 at 8.07.20 PM](attached://0013d519a2571332c98279bc473b4b72 402x434) " FOLDED="false" POSITION="right" ID="f0c59d092316b666824f8ddd">
                <edge COLOR="#a7d971"/>
                <font NAME="Helvetica" SIZE="50"/>
            </node>
        </node>
        <node TEXT="" FOLDED="false" POSITION="left" ID="f4cc1bbb9c9ce262d4f03038" X_COGGLE_JOINEDTO="5d8cd66a1730ee3c1c3f393e">
            <edge COLOR="#0a660d"/>
            <font NAME="Helvetica" SIZE="30"/>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT=" ![Screen Shot 2019-09-26 at 3.20.45 PM](attached://a820ca935685ccd4b340dfd04ead93a2 300x192) " FOLDED="false" POSITION="right" ID="490f531baa4490233f09cccb" X_COGGLE_POSX="-3049" X_COGGLE_POSY="-1410">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="50"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT=" ![Screen Shot 2019-09-26 at 3.26.21 PM](attached://ef8114d5121284f83036bf82c238d27a 300x173) " FOLDED="false" POSITION="right" ID="7569bb874ca832baf80aefef" X_COGGLE_POSX="-3028" X_COGGLE_POSY="-1109">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="50"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="CABLING (Layer 1)" FOLDED="false" POSITION="right" ID="0c6df5e8d4617d68adc9439f" X_COGGLE_POSX="-1505" X_COGGLE_POSY="-811">
        <edge COLOR="#e68782"/>
        <font NAME="Helvetica" SIZE="25"/>
        <node TEXT="Fire Rating" FOLDED="false" POSITION="right" ID="952f5029566e17c0f3b1ff1c">
            <edge COLOR="#e47b78"/>
            <font NAME="Helvetica" SIZE="15"/>
            <node TEXT="Plenum" FOLDED="false" POSITION="right" ID="8399e44fd57978e4792b4477">
                <edge COLOR="#e67e7a"/>
                <font NAME="Helvetica" SIZE="15"/>
            </node>
            <node TEXT="Riser" FOLDED="false" POSITION="right" ID="19c061fc9b04de8ead56097a">
                <edge COLOR="#e58481"/>
                <font NAME="Helvetica" SIZE="15"/>
            </node>
        </node>
        <node TEXT="COPPER" FOLDED="false" POSITION="left" ID="09d16019e560456fdf241d63">
            <edge COLOR="#e68782"/>
            <font NAME="Helvetica" SIZE="15"/>
            <node TEXT="TWISTED PAIR" FOLDED="false" POSITION="left" ID="cf25e2389dbbabf16b107215">
                <edge COLOR="#e4817e"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT=" ![Screen Shot 2019-09-28 at 11.57.05 PM](attached://eeba2865111302ddd84a2ff754b9aabf 300x252) " FOLDED="false" POSITION="left" ID="58fa9919647992d823ba943e">
                    <edge COLOR="#e27574"/>
                    <font NAME="Helvetica" SIZE="50"/>
                </node>
                <node TEXT="UTP" FOLDED="false" POSITION="left" ID="65bbd050438dabc50b239ab6">
                    <edge COLOR="#e57775"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="STP" FOLDED="false" POSITION="left" ID="268c5eee371b89d5fa4fd7d4">
                    <edge COLOR="#e68786"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="CAT 7" FOLDED="false" POSITION="left" ID="cbef3408f49b3ef1495a8fca">
                    <edge COLOR="#e78987"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="600 MHZ" FOLDED="false" POSITION="left" ID="9765bd846219b51519b48788">
                        <edge COLOR="#e88382"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="10+ GBPS" FOLDED="false" POSITION="left" ID="13594a7f4bc5372e655c0d18">
                        <edge COLOR="#e88282"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="CAT 6a" FOLDED="false" POSITION="left" ID="6f71b9de078ea3be9d05fcf0">
                    <edge COLOR="#e58281"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="500 MHZ" FOLDED="false" POSITION="left" ID="aca21f842ab65552082baa67">
                        <edge COLOR="#e47978"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="10 GBPS" FOLDED="false" POSITION="left" ID="72aa7121c07a46a060597e9b">
                        <edge COLOR="#e78281"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="CAT 6" FOLDED="false" POSITION="left" ID="afbfdecd0cc5f1c33d020b82">
                    <edge COLOR="#e58a87"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="250 MHZ" FOLDED="false" POSITION="left" ID="f4d3d588b19ee41de64b4169">
                        <edge COLOR="#e78c8b"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="10 GBPS" FOLDED="false" POSITION="left" ID="afa281602453e4faa29cffb2">
                        <edge COLOR="#e38887"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="CAT 5e" FOLDED="false" POSITION="left" ID="00188fbfdb82f19dca7c970a">
                    <edge COLOR="#e88d8a"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="100 MHZ" FOLDED="false" POSITION="left" ID="52a151e3614d4f846963ef4e">
                        <edge COLOR="#ea908e"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="1 GBPS" FOLDED="false" POSITION="left" ID="28fae2e75c12b7dcd1fa42c2">
                        <edge COLOR="#e89190"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="CAT 5" FOLDED="false" POSITION="left" ID="66704f978aea3004a8e67770">
                    <edge COLOR="#e58481"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="100 MHZ" FOLDED="false" POSITION="left" ID="85f384e12a37844531baf981">
                        <edge COLOR="#e37f7d"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="100 MBPS" FOLDED="false" POSITION="left" ID="e983c288b5cb54ba988df6c6">
                        <edge COLOR="#e27e7e"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="CAT 3" FOLDED="false" POSITION="left" ID="7e30b0f59423aaaa94426475">
                    <edge COLOR="#e98a87"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="16 MHZ" FOLDED="false" POSITION="left" ID="c1406c76ff947de0a58bfc62">
                        <edge COLOR="#ea807e"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="16 MBPS" FOLDED="false" POSITION="left" ID="2b81d5d4789dbbfa4b012d0c">
                        <edge COLOR="#ea8686"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
            </node>
            <node TEXT="CONNECTIONS" FOLDED="false" POSITION="left" ID="5a8bf00b27e1249478cec279">
                <edge COLOR="#e78c89"/>
                <font NAME="Helvetica" SIZE="15"/>
            </node>
            <node TEXT="Coaxial" FOLDED="false" POSITION="left" ID="3f9dabb560561a9f7e813046">
                <edge COLOR="#e78e8b"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT="RG-58" FOLDED="false" POSITION="left" ID="f5c8cc1fdaa752df6cf68594">
                    <edge COLOR="#e89392"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="50 OHM" FOLDED="false" POSITION="left" ID="6ef3f7d3bcc9a6267051e2e3">
                        <edge COLOR="#e88a88"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="RG-6" FOLDED="false" POSITION="left" ID="a2084e8256baf73bb8ad9fce">
                    <edge COLOR="#e79391"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="75 OHM" FOLDED="false" POSITION="left" ID="399adf47c5fd3ddc1bbcdae9">
                        <edge COLOR="#e48b8b"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="RG-59" FOLDED="false" POSITION="left" ID="0151d3ae0eba0ab0ba8eeb7a">
                    <edge COLOR="#e48482"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="75 OHM" FOLDED="false" POSITION="left" ID="9a75167427c914f1f1248d7f">
                        <edge COLOR="#e68888"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
            </node>
        </node>
        <node TEXT="FIBER" FOLDED="false" POSITION="left" ID="dc9dc1eb1deddde59090706e">
            <edge COLOR="#e68782"/>
            <font NAME="Helvetica" SIZE="15"/>
            <node TEXT="Connections" FOLDED="false" POSITION="left" ID="a0f5fd76c1925ba06030624a">
                <edge COLOR="#e78c89"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT="MT-RJ" FOLDED="false" POSITION="left" ID="3b2b9ce3118f30e544432669">
                    <edge COLOR="#e9908f"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="LC" FOLDED="false" POSITION="left" ID="7b4ebe61c0c44657f4f69695">
                    <edge COLOR="#e67f7e"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="ST" FOLDED="false" POSITION="left" ID="b68f188129debf558c420dce">
                    <edge COLOR="#e78d8b"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="SC" FOLDED="false" POSITION="left" ID="f0cc38610882ce052377f7ff">
                    <edge COLOR="#e89594"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
            </node>
            <node TEXT="MMF" FOLDED="false" POSITION="left" ID="ee73e126fde1ec57059c2805">
                <edge COLOR="#e5817d"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT="Uses LEDS" FOLDED="false" POSITION="left" ID="33fb1b2ccabaad2211aa819b">
                    <edge COLOR="#e58583"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="850 nm" FOLDED="false" POSITION="left" ID="57bff0bc3a9a4920906da713">
                    <edge COLOR="#e47e7c"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
            </node>
            <node TEXT="SMF" FOLDED="false" POSITION="left" ID="1c9f0b6b48bec5b1a1b1c668">
                <edge COLOR="#e3807d"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT="Uses Lasers" FOLDED="false" POSITION="left" ID="e4ad37dd8b5b8404f1784d0f">
                    <edge COLOR="#e68786"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="1310 nm / 1550 nm" FOLDED="false" POSITION="left" ID="3b986196f2ec383961b877c0">
                    <edge COLOR="#e58887"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
            </node>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="Switching (Layer 2)" FOLDED="false" POSITION="right" ID="52bbcdbc79b7d2bd6d91d477" X_COGGLE_POSX="1996" X_COGGLE_POSY="-620">
        <edge COLOR="#9ed56b"/>
        <font NAME="Helvetica" SIZE="29"/>
        <node TEXT="VLAN" FOLDED="false" POSITION="right" ID="844cbdbb5c6620625e53e169">
            <edge COLOR="#9ad163"/>
            <font NAME="Helvetica" SIZE="32"/>
            <node TEXT="Separate VLANS cannot talk to each other without a router
" FOLDED="false" POSITION="right" ID="a32bafd217e7efbb71af7a55">
                <edge COLOR="#97d05a"/>
                <font NAME="Helvetica" SIZE="20"/>
            </node>
            <node TEXT="VLAN uses switch ports as its broadcast domain
" FOLDED="false" POSITION="right" ID="0a61cb18fdf423c827de31bf">
                <edge COLOR="#96cd5b"/>
                <font NAME="Helvetica" SIZE="20"/>
            </node>
            <node TEXT="Switches use VLAN ID's to route traffic
" FOLDED="false" POSITION="right" ID="657ca1654a75d9475e2e9511">
                <edge COLOR="#96cd5b"/>
                <font NAME="Helvetica" SIZE="20"/>
            </node>
            <node TEXT="Create VLANs based on Workstation, Workgroup, Protocol, Service (Not just physical location)
" FOLDED="false" POSITION="right" ID="21208885a866c9b1f495a4db">
                <edge COLOR="#9dd363"/>
                <font NAME="Helvetica" SIZE="20"/>
            </node>
            <node TEXT="Trunking (802.1q?)" FOLDED="false" POSITION="right" ID="b085c409392405cbf9aac3ba">
                <edge COLOR="#9cd163"/>
                <font NAME="Helvetica" SIZE="20"/>
                <node TEXT="Used when VLAN spans more than one switch" FOLDED="false" POSITION="right" ID="7c0a619111aca18bcb69a4d2">
                    <edge COLOR="#98cc5c"/>
                    <font NAME="Helvetica" SIZE="20"/>
                </node>
            </node>
        </node>
        <node TEXT="Spanning Tree Protocol 
(802.1D)(Layer 2)" FOLDED="false" POSITION="right" ID="89cf6d093baa61fffcbf34fa">
            <edge COLOR="#9ed56b"/>
            <font NAME="Helvetica" SIZE="33"/>
            <node TEXT="STATES" FOLDED="false" POSITION="right" ID="299b87735a2b5a12fabc58c0">
                <edge COLOR="#9ed56b"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT="Blocking" FOLDED="false" POSITION="right" ID="129b3c9247001dcc615cf2a5">
                    <edge COLOR="#9ed56b"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="Listening" FOLDED="false" POSITION="right" ID="808cdb70e971e03069d06c1f">
                    <edge COLOR="#9ed56b"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="Learning" FOLDED="false" POSITION="right" ID="0b70caf125f20d2886a2d9b7">
                    <edge COLOR="#9ed56b"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="Forwarding" FOLDED="false" POSITION="right" ID="e0973fbd3f2934449c68c8bd">
                    <edge COLOR="#9ed56b"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="Disabled" FOLDED="false" POSITION="right" ID="e4c13670eb35703915b2623e">
                    <edge COLOR="#9ed56b"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
            </node>
            <node TEXT="Prevent loops in bridged (switched) networks" FOLDED="false" POSITION="right" ID="d7aa6230e2487835f39a18ab">
                <edge COLOR="#9ed56b"/>
                <font NAME="Helvetica" SIZE="15"/>
            </node>
            <node TEXT="RSTP (802.1W)" FOLDED="false" POSITION="right" ID="9d9ee40d91846b3973060f34">
                <edge COLOR="#a2d66e"/>
                <font NAME="Helvetica" SIZE="15"/>
            </node>
            <node TEXT="Shortest Path Bridge (SPB)(802.1aq)" FOLDED="false" POSITION="right" ID="8ae5de12300587cd1f4dbfe5">
                <edge COLOR="#9ed369"/>
                <font NAME="Helvetica" SIZE="15"/>
                <node TEXT="Adds Layer 3 routing functions to Layer 2 switching" FOLDED="false" POSITION="right" ID="9389f47b5a79b149ba7ae7f9">
                    <edge COLOR="#a6d672"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
            </node>
        </node>
        <node TEXT="" FOLDED="false" POSITION="left" ID="68bd40317d66a452a5ee2923" X_COGGLE_JOINEDTO="5d8cd66a1730ee3c1c3f393e">
            <edge COLOR="#a2d470"/>
            <font NAME="Helvetica" SIZE="33"/>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="NETWORK PORTS and PROTOCOLS" FOLDED="false" POSITION="right" ID="ccf6f7e8f096273e6dcded3d" X_COGGLE_POSX="-448" X_COGGLE_POSY="398">
        <edge COLOR="#eed666"/>
        <font NAME="Helvetica" SIZE="31"/>
        <node TEXT="" FOLDED="false" POSITION="right" ID="c4a865b58537eb729dd4ee4d" X_COGGLE_JOINEDTO="5d8cd66a1730ee3c1c3f393e">
            <edge COLOR="#ecd160"/>
            <font NAME="Helvetica" SIZE="13"/>
        </node>
        <node TEXT="E-mail" FOLDED="false" POSITION="left" ID="44b13a34efeaaa4ce3f01b58">
            <edge COLOR="#ebd95f"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="POP/IMAP" FOLDED="false" POSITION="left" ID="19d9bec1fe2859bc461cabc3">
                <edge COLOR="#efa670"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Receive emails from email server" FOLDED="false" POSITION="left" ID="ceeaf9f69db3c4f8a08e3ae9">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Authenticate and transfer" FOLDED="false" POSITION="left" ID="9edbff4afa2e0d6b6eb98652">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="POP3: TCP/110" FOLDED="false" POSITION="left" ID="f51331c896f03270c13e03f6">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="12"/>
                    <node TEXT="Receive emails from email server" FOLDED="false" POSITION="left" ID="824cb8ac545b3aee17ab7110">
                        <edge COLOR="#edd569"/>
                        <font NAME="Helvetica" SIZE="12"/>
                    </node>
                    <node TEXT="Post Office Protocol" FOLDED="false" POSITION="left" ID="511b0d72ec063a3396e845d2">
                        <edge COLOR="#ecd360"/>
                        <font NAME="Helvetica" SIZE="12"/>
                    </node>
                </node>
                <node TEXT="IMAP 4: TCP/143" FOLDED="false" POSITION="left" ID="f4024f87626861cddbe38c26">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="Internet Message Access Protocol" FOLDED="false" POSITION="left" ID="c4c267160a492329fb41ef96">
                        <edge COLOR="#e8d060"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Includes management of email 
inbox from multiple clients
" FOLDED="false" POSITION="left" ID="57fc013ad28c30e6729bff46">
                        <edge COLOR="#e8cf60"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
            </node>
            <node TEXT="SMTP: TCP/25" FOLDED="false" POSITION="left" ID="6e348db9cf21837b8ba7dae2">
                <edge COLOR="#efa670"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Server to server mail transfer" FOLDED="false" POSITION="left" ID="93d433ef3a8b1cd85b9c2365">
                    <edge COLOR="#ebd35b"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Also send mail from device to server" FOLDED="false" POSITION="left" ID="dd2d4b4382f33c976390121d">
                    <edge COLOR="#ebd771"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
        </node>
        <node TEXT="VOIP" FOLDED="false" POSITION="right" ID="ee1257dbcdf5ad711042d393">
            <edge COLOR="#eeda66"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="H.323: TCP/1720" FOLDED="false" POSITION="right" ID="292be190d68928e604f61bf6">
                <edge COLOR="#efd75f"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="VoIP Signaling" FOLDED="false" POSITION="right" ID="cd976d9824ec699f7cb602d9">
                    <edge COLOR="#efd667"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Setup and manage VoIP sessions" FOLDED="false" POSITION="right" ID="82abbb0921197fb10e2a75b3">
                    <edge COLOR="#efd357"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="SIP" FOLDED="false" POSITION="right" ID="6ef53d185deeede576b38cd5">
                <edge COLOR="#ebd45d"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Session Initiation Protocol" FOLDED="false" POSITION="right" ID="e219e9b22ebf7cfb316b5f2f">
                    <edge COLOR="#ead15c"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="VOIP Signaling" FOLDED="false" POSITION="right" ID="edd1092923546acb8cd71255">
                    <edge COLOR="#ead366"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="TCP/5060, TCP/5061" FOLDED="false" POSITION="right" ID="c4af1c741b2822c4688fc06e">
                    <edge COLOR="#edd257"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
        </node>
        <node TEXT="WEB" FOLDED="false" POSITION="right" ID="131e73c1c4bb5c699c98a078">
            <edge COLOR="#eed962"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="HTTP: TCP/80" FOLDED="false" POSITION="right" ID="cd2ccce12bbfa6e538187b49">
                <edge COLOR="#edd769"/>
                <font NAME="Helvetica" SIZE="12"/>
            </node>
            <node TEXT="HTTPS: TCP/443" FOLDED="false" POSITION="right" ID="8f3f3bca0cc646e9e5f2d9a2">
                <edge COLOR="#edd767"/>
                <font NAME="Helvetica" SIZE="12"/>
            </node>
        </node>
        <node TEXT="File Transfer" FOLDED="false" POSITION="left" ID="50267115ebac3d34f7faf1de">
            <edge COLOR="#ebd95f"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="FTP" FOLDED="false" POSITION="left" ID="956cc1b985e4185bccc19a7c">
                <edge COLOR="#ffaa38"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="TCP/20 (ACTIVE MODE DATA)" FOLDED="false" POSITION="left" ID="dd4589b25c102f8c0c230bc0">
                    <edge COLOR="#fea331"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
                <node TEXT="TCP/21 (CONTROL)" FOLDED="false" POSITION="left" ID="f843d15d623922b89d4cd8fe">
                    <edge COLOR="#fda63a"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
            </node>
            <node TEXT="TFTP: UDP/69" FOLDED="false" POSITION="left" ID="d85c9c1e698137aa2176b90e">
                <edge COLOR="#ffaa38"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Simple file transfer" FOLDED="false" POSITION="left" ID="b463ebdddea75b3fb86e360e">
                    <edge COLOR="#ebd355"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="No Authentication" FOLDED="false" POSITION="left" ID="6f54238ff9f36b0be3ec7cda">
                    <edge COLOR="#ebd459"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="SMB: TCP/445, 137-139 NetBIOS" FOLDED="false" POSITION="left" ID="9fa4282828e8593400e1e37e">
                <edge COLOR="#ffaa38"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Server Message Block" FOLDED="false" POSITION="left" ID="05e77670b651cdf9a596c0f5">
                    <edge COLOR="#edd461"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Also called **CIFS** (Common Internet File System)" FOLDED="false" POSITION="left" ID="6a9886ac64e8d5d8086be8bc">
                    <edge COLOR="#ecd462"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
                <node TEXT="Used for sharing access to resources such as files and printers on a windows network" FOLDED="false" POSITION="left" ID="e13eb7eb931327cfc60e6103">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="SFTP: TCP/22" FOLDED="false" POSITION="left" ID="25396a73d581f78f54d7d41f">
                <edge COLOR="#ffaa38"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Encrypted with SSH" FOLDED="false" POSITION="left" ID="94f500a422ccb28e69d1482b">
                    <edge COLOR="#e8d46b"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
            <node TEXT="SCP" FOLDED="false" POSITION="left" ID="91674b715a31d5f12e0b9f20">
                <edge COLOR="#ffaa38"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Secure Copy Protocol" FOLDED="false" POSITION="left" ID="5c35d2934716c23ba70221e8">
                    <edge COLOR="#ebd054"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
            </node>
        </node>
        <node TEXT="OTHER" FOLDED="false" POSITION="right" ID="2296a489fd9139357ae21fe8">
            <edge COLOR="#ebd95f"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="NTP: UDP/123" FOLDED="false" POSITION="right" ID="7adede3ad9aefae1c24a96d4">
                <edge COLOR="#e8e525"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Network Time Protocol" FOLDED="false" POSITION="right" ID="2217dc2aeb2838b5088c48f7">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
            </node>
            <node TEXT="DNS: UDP 53" FOLDED="false" POSITION="right" ID="d0d1b5f6ad6b7e94a170bf60">
                <edge COLOR="#ebd95f"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Domain Name Server - Assigns name to IP address" FOLDED="false" POSITION="right" ID="37324896c856196c3b50f712">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
            </node>
            <node TEXT="LDAP: TCP/389" FOLDED="false" POSITION="right" ID="049ee13d557a62959bc88844">
                <edge COLOR="#e8e525"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="(Lightweight Directory Access Protocol) - 
Store and retrieve information in a network directory" FOLDED="false" POSITION="right" ID="0e6266f635d9c5b9ea285095">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="17"/>
                </node>
                <node TEXT="LDAPS (LDAP Secure): TCP/636" FOLDED="false" POSITION="right" ID="90646a1d388689826fcad6ca">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="12"/>
                    <node TEXT="LDAP over SSL" FOLDED="false" POSITION="right" ID="582341d98e20116f42a344e9">
                        <edge COLOR="#e8e525"/>
                        <font NAME="Helvetica" SIZE="12"/>
                    </node>
                </node>
            </node>
            <node TEXT="DHCP" FOLDED="false" POSITION="right" ID="de17d7508127bcfb11e6aac8">
                <edge COLOR="#e8e525"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Automatic configuration of IP addresses, subnet mask and other options
" FOLDED="false" POSITION="right" ID="3510d1b035eff78838f70f24">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
                <node TEXT="UDP/68 (Clients)" FOLDED="false" POSITION="right" ID="b509e94c94ce6d52b2806316">
                    <edge COLOR="#e8e125"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="Carries the DHCP service on the BOOTP protocol" FOLDED="false" POSITION="right" ID="5d253a8cc10aed5ee297eaec">
                        <edge COLOR="#ebe126"/>
                        <font NAME="Helvetica" SIZE="12"/>
                    </node>
                </node>
                <node TEXT="UDP/67 (Servers)" FOLDED="false" POSITION="right" ID="5c0735ff5e9fffce1aa728ee">
                    <edge COLOR="#e8e525"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="Uses port 67 to find a BOOTP server" FOLDED="false" POSITION="right" ID="62b7eab60344f39089dc7d9e">
                        <edge COLOR="#e9e326"/>
                        <font NAME="Helvetica" SIZE="12"/>
                    </node>
                </node>
                <node TEXT="BOOTP (Bootstrap Protocol)" FOLDED="false" POSITION="right" ID="bfd386ff0c4982b0bd651b71">
                    <edge COLOR="#e8e225"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="The actual protocol that assigns addresses to devices when a device boots up without user involvement" FOLDED="false" POSITION="right" ID="6dcde0bee69eef1bbcfe805d">
                        <edge COLOR="#e6de2e"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
            </node>
        </node>
        <node TEXT="Control Protocols" FOLDED="false" POSITION="left" ID="68fcc74357dbddbe41acdc6d">
            <edge COLOR="#ebd95f"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="ICMP" FOLDED="false" POSITION="left" ID="bc9ecb91aa18e3d1ffecf481">
                <edge COLOR="#ead35c"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Internet Control Message Protocol" FOLDED="false" POSITION="left" ID="779649efb74b1ecedbe0bd3f">
                    <edge COLOR="#e8cf5c"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="(ping)" FOLDED="false" POSITION="left" ID="25d555b84558e9ac0d03a131">
                        <edge COLOR="#e7cd63"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
            </node>
        </node>
        <node TEXT="Network Management" FOLDED="false" POSITION="left" ID="040086cf69c67bbd43ed3ca0">
            <edge COLOR="#ead454"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="SNMP: UDP/161" FOLDED="false" POSITION="left" ID="ce2e305657d448089f98511d">
                <edge COLOR="#eed75e"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Gather statistics from network devices" FOLDED="false" POSITION="left" ID="ecd12433e320e8ac1ea1bf44">
                    <edge COLOR="#f0d556"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
                <node TEXT="Simple Network Management Protocol" FOLDED="false" POSITION="left" ID="47429bda46fa471f8dd72baa">
                    <edge COLOR="#eed664"/>
                    <font NAME="Helvetica" SIZE="13"/>
                </node>
            </node>
            <node TEXT="SSH: TCP/22" FOLDED="false" POSITION="left" ID="faa8b1661edd69ad7a12cfff">
                <edge COLOR="#ebd868"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="RDP TCP/3389" FOLDED="false" POSITION="left" ID="f976b756a342e70d88c7b04a">
                <edge COLOR="#ecd652"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="TELNET: TCP/23" FOLDED="false" POSITION="left" ID="57accb63f6876fd74f12ccd8">
                <edge COLOR="#e7ce4f"/>
                <font NAME="Helvetica" SIZE="13"/>
                <node TEXT="Username and Password authentication" FOLDED="false" POSITION="left" ID="5bc9172c3a14c933f5c340f2">
                    <edge COLOR="#e6ca4c"/>
                    <font NAME="Helvetica" SIZE="12"/>
                </node>
            </node>
        </node>
        <node TEXT="Protocol Types" FOLDED="false" POSITION="right" ID="f30d7789296060509425afa2">
            <edge COLOR="#eed466"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="UDP" FOLDED="false" POSITION="left" ID="a20e18682de550e152398475">
                <edge COLOR="#eed470"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="ICMP" FOLDED="false" POSITION="right" ID="0a4aa2620cf4d09e25467930">
                <edge COLOR="#eed36e"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="TCP" FOLDED="false" POSITION="left" ID="2fcec2952cd8afe4ff3fc2d7">
                <edge COLOR="#ebce5d"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="IP" FOLDED="false" POSITION="right" ID="4d4626e857c5d26ad6106647">
                <edge COLOR="#f0d670"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
        </node>
        <node TEXT="IP (Layer 3)" FOLDED="false" POSITION="right" ID="65db2be6c29314d03c0ee066">
            <edge COLOR="#eed25e"/>
            <font NAME="Helvetica" SIZE="34"/>
            <node TEXT="MultiCast" FOLDED="false" POSITION="left" ID="003f6954fb6e9ebe7949e9cc">
                <edge COLOR="#ecd36a"/>
                <font NAME="Helvetica" SIZE="24"/>
                <node TEXT="IGMP (Internet Group Management Protocol" FOLDED="false" POSITION="left" ID="5b6e963049063b01ebbaffe8">
                    <edge COLOR="#ecd45a"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="Used to identify group members and to forward multicast packets where group members reside" FOLDED="false" POSITION="left" ID="236c6ebde796cd146b052fee">
                        <edge COLOR="#efd663"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Process" FOLDED="false" POSITION="left" ID="9082bbefe73c6071c4c963c6">
                        <edge COLOR="#eacf54"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="1. Router sends out host information query 224.0.0.1" FOLDED="false" POSITION="left" ID="1eda1885efcbbe0860e4b77d">
                            <edge COLOR="#ecd050"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                        <node TEXT="2. Hosts that are members of any group respond with list of groups they belong to" FOLDED="false" POSITION="left" ID="a3c3d9d41d7580f9ac8a09de">
                            <edge COLOR="#ecd25e"/>
                            <font NAME="Helvetica" SIZE="13"/>
                            <node TEXT="224.0.0.1  -  239.255.255.255" FOLDED="false" POSITION="left" ID="8a512acc498bb81cc67f9ba5">
                                <edge COLOR="#ebcd4f"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                        </node>
                        <node TEXT="3. Router uses responses to compose a list of groups on the subnet that have group members" FOLDED="false" POSITION="left" ID="381227a7996091ce8f3da5e1">
                            <edge COLOR="#ead15e"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                        <node TEXT="4. When a host joins a new group, it automatically sends a join group message to the router.  " FOLDED="false" POSITION="left" ID="214924e4db509948235b9984">
                            <edge COLOR="#edd151"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                        <node TEXT="5. IGMP router reports to upstream routers that they have members of a specific group" FOLDED="false" POSITION="left" ID="edb995706b7b59feb94da447">
                            <edge COLOR="#ecd05e"/>
                            <font NAME="Helvetica" SIZE="13"/>
                            <node TEXT="Upstream routers are the routers that exist between the router and the server that sends out the multicast data stream. They keep track of downstream routers that have group members" FOLDED="false" POSITION="left" ID="b99cbc8b4d0f52fad765e9ab">
                                <edge COLOR="#eacc5b"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                        </node>
                    </node>
                </node>
                <node TEXT="Process" FOLDED="false" POSITION="left" ID="9a987c237235b4c5ef893e75">
                    <edge COLOR="#ebcf67"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="1. Sending server sends packets addressed to the multicast group
" FOLDED="false" POSITION="left" ID="646d3cdbd705e35115058de4">
                        <edge COLOR="#e9cc69"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="2. Routers receive the multicast packets and check their lists of group members
" FOLDED="false" POSITION="left" ID="52d40f9cde6f33c41189565d">
                        <edge COLOR="#ebcc65"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="If the router is connected to a subnet that has group members, or if the subnet includes a downstream router with group members, the multicast packet is sent on that subnet
" FOLDED="false" POSITION="left" ID="b17cfa1b835c849b26af12d7">
                            <edge COLOR="#ebc961"/>
                            <font NAME="Helvetica" SIZE="12"/>
                        </node>
                        <node TEXT="If a subnet does not have any group members, the packet is not forwarded on that subnet
" FOLDED="false" POSITION="left" ID="5e951dc6ece05a673a23fa90">
                            <edge COLOR="#eccb68"/>
                            <font NAME="Helvetica" SIZE="12"/>
                        </node>
                        <node TEXT="If a router does not have any subnets with group members, the packet is dropped and not forwarded
" FOLDED="false" POSITION="left" ID="68b29562bdd8a5c6a95f8cc7">
                            <edge COLOR="#eacb6c"/>
                            <font NAME="Helvetica" SIZE="12"/>
                        </node>
                    </node>
                    <node TEXT="3. Each intermediary router performs the same tasks until the data stream eventually reaches the multicast client
" FOLDED="false" POSITION="left" ID="fed4b36debf32449f80ea399">
                        <edge COLOR="#edcf69"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
                <node TEXT="Without Multicasting" FOLDED="false" POSITION="left" ID="fb0cb65749a5f21cdbddef23">
                    <edge COLOR="#edd371"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="Unicast" FOLDED="false" POSITION="left" ID="ef73cf45e509a64f39d4d1cf">
                        <edge COLOR="#edd369"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="Messages are sent to a specific host address.  The sending device must know the IP address of all recipients, and must create a separate packet for each destination device (one-to-one)" FOLDED="false" POSITION="left" ID="cb7831b7df234bded64f2e30">
                            <edge COLOR="#eccf62"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                    </node>
                    <node TEXT="Broadcast" FOLDED="false" POSITION="left" ID="93dd6ab1d349571567641610">
                        <edge COLOR="#efd35f"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="A single packet is sent to the broadcast and is processed by all hosts.  All hosts, and not just group members, receive the packet.  Broadcast packets are not typically forwarded by routers, so broadcast traffic is limited to within a single subnet" FOLDED="false" POSITION="left" ID="fbad36f8c04eec99a60a3eb7">
                            <edge COLOR="#edcd57"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                    </node>
                </node>
                <node TEXT="Additional Facts" FOLDED="false" POSITION="left" ID="cfac8cb06355920b92495884">
                    <edge COLOR="#ebcf65"/>
                    <font NAME="Helvetica" SIZE="13"/>
                    <node TEXT="MAC address begins with 01-00-5e" FOLDED="false" POSITION="left" ID="a8188f5c8804b5949f628688">
                        <edge COLOR="#efd069"/>
                        <font NAME="Helvetica" SIZE="13"/>
                        <node TEXT="The last portion being a form of the IP multicast group address
" FOLDED="false" POSITION="left" ID="f6c24c0ef0d593910e4ca1f8">
                            <edge COLOR="#edcc69"/>
                            <font NAME="Helvetica" SIZE="13"/>
                        </node>
                    </node>
                    <node TEXT="Frames that contain multicast traffic are sent to a special MAC address
" FOLDED="false" POSITION="left" ID="47bbc70b44998a0656cf53fc">
                        <edge COLOR="#edcf5f"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="IGMP snooping on a switch allows the switch to control which ports get IGMP traffic for a specific group.  " FOLDED="false" POSITION="left" ID="1c0e16a0b2a717086f26286f">
                        <edge COLOR="#eed16e"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                    <node TEXT="Multicasting creates logical groups of hosts, messages sent to the group are received by all group members.
" FOLDED="false" POSITION="left" ID="2ee2d472c6c657b73e41c81f">
                        <edge COLOR="#ebca59"/>
                        <font NAME="Helvetica" SIZE="13"/>
                    </node>
                </node>
            </node>
            <node TEXT="IPv4" FOLDED="false" POSITION="left" ID="8459cf6f1a66a0f2e8d56c8b">
                <edge COLOR="#ebd05f"/>
                <font NAME="Helvetica" SIZE="50"/>
                <node TEXT="32 Bit address" FOLDED="false" POSITION="left" ID="4a9dc9f4aa894f9766badfd7">
                    <edge COLOR="#ecd16a"/>
                    <font NAME="Helvetica" SIZE="34"/>
                </node>
                <node TEXT="Classes" FOLDED="false" POSITION="left" ID="85a6c8ea368500d14a3f691c">
                    <edge COLOR="#e9cd63"/>
                    <font NAME="Helvetica" SIZE="34"/>
                    <node TEXT="A" FOLDED="false" POSITION="left" ID="12ac174a91adfe74cdacae1f">
                        <edge COLOR="#eaca5c"/>
                        <font NAME="Helvetica" SIZE="34"/>
                        <node TEXT="1.0.0.0 - 126.255.255.255" FOLDED="false" POSITION="left" ID="1e1d62f9a0992e3a61359865">
                            <edge COLOR="#ecca60"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                        <node TEXT="Subnet: 255.0.0.0" FOLDED="false" POSITION="left" ID="cff66c1104031e06dd146d97">
                            <edge COLOR="#e7c353"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                    </node>
                    <node TEXT="B" FOLDED="false" POSITION="left" ID="1e1ef7178c4b22a82edb7100">
                        <edge COLOR="#eacb62"/>
                        <font NAME="Helvetica" SIZE="34"/>
                        <node TEXT="128.0.0.0 - 191.255.255.255" FOLDED="false" POSITION="left" ID="77dc69f50c8946b4a9ed01b3">
                            <edge COLOR="#e7c55b"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                        <node TEXT="Subnet: 255.255.0.0" FOLDED="false" POSITION="left" ID="db39ccab1c605bd6cc126e68">
                            <edge COLOR="#e9c861"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                    </node>
                    <node TEXT="C" FOLDED="false" POSITION="left" ID="9434cd5da930f8c2f580ebba">
                        <edge COLOR="#e8ca66"/>
                        <font NAME="Helvetica" SIZE="34"/>
                        <node TEXT="192.0.0.0 - 223.255.255.255" FOLDED="false" POSITION="left" ID="5e83acfc3c5b512a7d5da677">
                            <edge COLOR="#ebcb69"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                        <node TEXT="Subnet: 255.255.255.0" FOLDED="false" POSITION="left" ID="f81d929e4f550e426426fb94">
                            <edge COLOR="#e9c65b"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                    </node>
                    <node TEXT="D" FOLDED="false" POSITION="left" ID="f0c28fa8162b1dcc232b25fd">
                        <edge COLOR="#e8ca64"/>
                        <font NAME="Helvetica" SIZE="34"/>
                        <node TEXT="224.0.0.0 - 239.255.255.255" FOLDED="false" POSITION="left" ID="7fd6126cea2dc6a457be5976">
                            <edge COLOR="#e7c869"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                    </node>
                    <node TEXT="E" FOLDED="false" POSITION="left" ID="17e992816d4961bde7419757">
                        <edge COLOR="#ebcc65"/>
                        <font NAME="Helvetica" SIZE="34"/>
                        <node TEXT="240.0.0.0 - 255.255.255.255" FOLDED="false" POSITION="left" ID="c872cc3eae74960308b0c249">
                            <edge COLOR="#eece6e"/>
                            <font NAME="Helvetica" SIZE="34"/>
                        </node>
                    </node>
                </node>
            </node>
            <node TEXT="**Routing (Layer 3)**" FOLDED="false" POSITION="right" ID="f7518d314b5cc0fbc8fe7971">
                <edge COLOR="#efa670"/>
                <font NAME="Helvetica" SIZE="40"/>
                <node TEXT="Routing Protocols" FOLDED="false" POSITION="right" ID="52b6275e5cd8c8d6aa5330d5">
                    <edge COLOR="#efaa7a"/>
                    <font NAME="Helvetica" SIZE="29"/>
                    <node TEXT="Distance Vector" FOLDED="false" POSITION="right" ID="c7a9516fc8dc09d49ebfb4bf">
                        <edge COLOR="#efa97c"/>
                        <font NAME="Helvetica" SIZE="32"/>
                        <node TEXT="RIP (Routing Information Protocol)" FOLDED="false" POSITION="right" ID="47930fd1a4d9c3b0ff6916d7">
                            <edge COLOR="#efa376"/>
                            <font NAME="Helvetica" SIZE="24"/>
                            <node TEXT="Best suited for small private networks" FOLDED="false" POSITION="right" ID="c8543468ffaddf187b35ba40">
                                <edge COLOR="#efa67e"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="IGP" FOLDED="false" POSITION="right" ID="ee22aced0f6d46091d89d9c2">
                                <edge COLOR="#f0a77f"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Uses Hop Count as Metric" FOLDED="false" POSITION="right" ID="9d650380578b2aba984bde73">
                                <edge COLOR="#eea47b"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Limited to 15 hops" FOLDED="false" POSITION="right" ID="fd080054b2177bab0482a3bc">
                                <edge COLOR="#ed9e72"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                        </node>
                    </node>
                    <node TEXT="Link State" FOLDED="false" POSITION="right" ID="df8f914682666e62db168302">
                        <edge COLOR="#f0af85"/>
                        <font NAME="Helvetica" SIZE="32"/>
                        <node TEXT="OPSF (Open Shortest Path First)" FOLDED="false" POSITION="right" ID="eca37704c87f48acbd354d66">
                            <edge COLOR="#efac84"/>
                            <font NAME="Helvetica" SIZE="23"/>
                            <node TEXT="Divides a large network into areas" FOLDED="false" POSITION="right" ID="3d8e52220ebfa3847e1b7530">
                                <edge COLOR="#eca37b"/>
                                <font NAME="Helvetica" SIZE="15"/>
                                <node TEXT="Each (AS) requires an area 0 that identifies the network backbone
" FOLDED="false" POSITION="right" ID="43b158d3212f3bd9202abc84">
                                    <edge COLOR="#eca079"/>
                                    <font NAME="Helvetica" SIZE="15"/>
                                </node>
                                <node TEXT="All areas are connected to area 0, either directly or indirectly through another area" FOLDED="false" POSITION="right" ID="aaeb2e08e1ec2a2ec4a3bee2">
                                    <edge COLOR="#eda784"/>
                                    <font NAME="Helvetica" SIZE="15"/>
                                </node>
                                <node TEXT="Routes between areas must pass through area 0
" FOLDED="false" POSITION="right" ID="711e0c80d6cdfd20198f4b3a">
                                    <edge COLOR="#e99d76"/>
                                    <font NAME="Helvetica" SIZE="15"/>
                                </node>
                            </node>
                            <node TEXT="IGP" FOLDED="false" POSITION="right" ID="75176a2bcb6584c61642dd84">
                                <edge COLOR="#efae8a"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="V1 Classfull / V2 Classless" FOLDED="false" POSITION="right" ID="ffaf0bbfe9705acd00672f45">
                                <edge COLOR="#eda37a"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Uses relative link cost for the metric" FOLDED="false" POSITION="right" ID="c8de8f5f7b250992eb3a3442">
                                <edge COLOR="#f1ab84"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="A router is the boundary between one area another" FOLDED="false" POSITION="right" ID="c263679219f401ffdaf16520">
                                <edge COLOR="#efa880"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Best suited for large private network" FOLDED="false" POSITION="right" ID="b3877dff0e137eda7d580cd6">
                                <edge COLOR="#f0a479"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                        </node>
                        <node TEXT="IS-IS (Intermediate System to Intermediate System)" FOLDED="false" POSITION="right" ID="9903af83fa7c653f661a37e0">
                            <edge COLOR="#f1b28c"/>
                            <font NAME="Helvetica" SIZE="22"/>
                            <node TEXT="Best suited for large private networks larger than OSPF" FOLDED="false" POSITION="right" ID="8afa36eafc8ce0cc5f3ed143">
                                <edge COLOR="#f3b693"/>
                                <font NAME="Helvetica" SIZE="19"/>
                                <node TEXT="Typically used in an ISP with IPv6" FOLDED="false" POSITION="right" ID="c77bb302751475050db08b7d">
                                    <edge COLOR="#f3ad87"/>
                                    <font NAME="Helvetica" SIZE="19"/>
                                </node>
                            </node>
                            <node TEXT="L1 routers share routes with in area. L2 routers share routes between areas
" FOLDED="false" POSITION="right" ID="c8ba1c6b42360b2d57da214d">
                                <edge COLOR="#f1b796"/>
                                <font NAME="Helvetica" SIZE="19"/>
                            </node>
                            <node TEXT="Uses relative link-state" FOLDED="false" POSITION="right" ID="f79c69d9c624867603b08458">
                                <edge COLOR="#f2b18d"/>
                                <font NAME="Helvetica" SIZE="19"/>
                            </node>
                            <node TEXT="Classless" FOLDED="false" POSITION="right" ID="1bfd592cbead8f6ddfdc2ae7">
                                <edge COLOR="#f1b796"/>
                                <font NAME="Helvetica" SIZE="19"/>
                            </node>
                            <node TEXT="Divides large networks into areas with no 0 requirement
" FOLDED="false" POSITION="right" ID="8adf1fb85508c584025f9a4d">
                                <edge COLOR="#f1b796"/>
                                <font NAME="Helvetica" SIZE="19"/>
                            </node>
                        </node>
                    </node>
                    <node TEXT="Hybrid" FOLDED="false" POSITION="right" ID="712d8ec706c066023ad3e048">
                        <edge COLOR="#f2af83"/>
                        <font NAME="Helvetica" SIZE="31"/>
                        <node TEXT="EIGRP (Enhanced Interior Gateway Routing Protocol)
" FOLDED="false" POSITION="right" ID="b9d4ffc9970e619cd4be4690">
                            <edge COLOR="#f1a678"/>
                            <font NAME="Helvetica" SIZE="23"/>
                            <node TEXT="Routing protocol developed by Cisco" FOLDED="false" POSITION="right" ID="8134b298158ce71c82d89753">
                                <edge COLOR="#f0a981"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Classless" FOLDED="false" POSITION="right" ID="c9ff10c2b9d9a80669433421">
                                <edge COLOR="#ef9e70"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Uses a composite number as a metric, which indicates bandwidth and delay
" FOLDED="false" POSITION="right" ID="141a2b7489781c1a096df08f">
                                <edge COLOR="#f0a479"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Best suited for medium to large private networks" FOLDED="false" POSITION="right" ID="551f358a20af54772be6dec2">
                                <edge COLOR="#efa174"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                        </node>
                        <node TEXT="BGP (Border Gateway Protocol)" FOLDED="false" POSITION="right" ID="83c4be6093499a6ef6cdefaa">
                            <edge COLOR="#f0ac83"/>
                            <font NAME="Helvetica" SIZE="24"/>
                            <node TEXT="Protocol used on the Internet" FOLDED="false" POSITION="right" ID="f524bd81399b156a073478fe">
                                <edge COLOR="#eda67e"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="EGP" FOLDED="false" POSITION="right" ID="f06eb916cd8d8f8f9ff4b365">
                                <edge COLOR="#f0af8b"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Uses paths, Rules, and policies instead of a metric
" FOLDED="false" POSITION="right" ID="964e7653c036346a1ff4e69d">
                                <edge COLOR="#f0a377"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                            <node TEXT="Classless" FOLDED="false" POSITION="right" ID="f677f4d38a2ea3c566eed63a">
                                <edge COLOR="#eea77f"/>
                                <font NAME="Helvetica" SIZE="15"/>
                            </node>
                        </node>
                    </node>
                </node>
                <node TEXT="Process of moving packets from one network to another
" FOLDED="false" POSITION="left" ID="dc156b8287f88217eff4f6eb">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="15"/>
                </node>
                <node TEXT="Terms" FOLDED="false" POSITION="right" ID="e5c26d7ee4991d93ebdaa2e0">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="Next hop" FOLDED="false" POSITION="right" ID="871599ffc65d5635bd7533d7">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Routing Table" FOLDED="false" POSITION="right" ID="300986fa4b0e26fc7d8cfbe5">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Default Route" FOLDED="false" POSITION="right" ID="ff8e1e9e765edde6e7ca1f0e">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Loopback Entry" FOLDED="false" POSITION="right" ID="3e04bc350b65dea1ef659b18">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
                <node TEXT="Classified by use" FOLDED="false" POSITION="right" ID="45ae315e1befa6f0192894e2">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="25"/>
                    <node TEXT="Exterior Routing" FOLDED="false" POSITION="right" ID="8cd3b1be3b042581e0763fd9">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="21"/>
                        <node TEXT="Routing of backbone of the internet" FOLDED="false" POSITION="right" ID="940bb0ce738dd39f466ccfd1">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                        <node TEXT="Exterior routing is done between Autonomous Systems
" FOLDED="false" POSITION="right" ID="8b92b16474952e6514006571">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                    </node>
                    <node TEXT="Interior Routing" FOLDED="false" POSITION="right" ID="ed3b46e2688a3aa172ee7cc4">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="21"/>
                        <node TEXT="Interior routing is done in an Autonomous System (AS)
" FOLDED="false" POSITION="right" ID="7b327488c1eebe932b763ecd">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                    </node>
                </node>
                <node TEXT="Packet (Layer 2)" FOLDED="false" POSITION="right" ID="08a50c3282d32f7b13161fe1">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="15"/>
                    <node TEXT="Header" FOLDED="false" POSITION="right" ID="4081aa07a7a71ea748e86ff9">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                        <node TEXT="Source/Destination IP" FOLDED="false" POSITION="right" ID="8790892cee5a8b7e1da7f3c4">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                    </node>
                    <node TEXT="Payload" FOLDED="false" POSITION="right" ID="3c957f7112471a8ed65e8473">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                        <node TEXT="Depends on protocol" FOLDED="false" POSITION="right" ID="484562ce3bf995357be8811a">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                    </node>
                </node>
                <node TEXT="How entries are added" FOLDED="false" POSITION="right" ID="a6d69ba8689595e6dc323879">
                    <edge COLOR="#efa670"/>
                    <font NAME="Helvetica" SIZE="21"/>
                    <node TEXT="Dynamic" FOLDED="false" POSITION="right" ID="55aa21688fc953c9ff3e63b8">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                        <node TEXT="Implemented by enabling a routing protocol" FOLDED="false" POSITION="right" ID="53fd66b5aad572b561adaf0a">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                        <node TEXT="Routing protocols use metric information to insert the best hop into the routing table
" FOLDED="false" POSITION="right" ID="8acfccb90a5c37830845592f">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                    </node>
                    <node TEXT="Static" FOLDED="false" POSITION="right" ID="45d3735a2369b552b3280ada">
                        <edge COLOR="#efa670"/>
                        <font NAME="Helvetica" SIZE="15"/>
                        <node TEXT="Manually added to router" FOLDED="false" POSITION="right" ID="bb39a50ba9f2166248fcaa65">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                        <node TEXT="Default route: 0.0.0.0" FOLDED="false" POSITION="right" ID="0fdd28d7c26f4f5748dcb50d">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="15"/>
                        </node>
                    </node>
                </node>
                <node TEXT="NAT (Network Address Translation)" FOLDED="false" POSITION="right" ID="981c0bd330a1219bc23cfd66">
                    <edge COLOR="#f0a775"/>
                    <font NAME="Helvetica" SIZE="27"/>
                    <node TEXT="Allows you to connect a private network to the Internet without obtaining registered addresses for every host
" FOLDED="false" POSITION="right" ID="9c8957dcd21875ec47d7efbd">
                        <edge COLOR="#f1a06c"/>
                        <font NAME="Helvetica" SIZE="22"/>
                    </node>
                    <node TEXT="Translates private addresses to the public NAT router" FOLDED="false" POSITION="right" ID="6721eaf38a71d95c52cd257e">
                        <edge COLOR="#f1a778"/>
                        <font NAME="Helvetica" SIZE="34"/>
                    </node>
                </node>
                <node TEXT="Routing Metrics" FOLDED="false" POSITION="right" ID="dcf57dc1465391984de03b5a">
                    <edge COLOR="#f1a876"/>
                    <font NAME="Helvetica" SIZE="21"/>
                    <node TEXT="Hop Count" FOLDED="false" POSITION="right" ID="200bcabd702100566e20736b">
                        <edge COLOR="#f1ab7d"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Bandwidth" FOLDED="false" POSITION="right" ID="644e38660a86a9e1708540ad">
                        <edge COLOR="#f0a16f"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Throughput" FOLDED="false" POSITION="right" ID="08e537521f1480b8e4b94823">
                        <edge COLOR="#f3a97a"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Link Utilization" FOLDED="false" POSITION="right" ID="7d9a0d3b8b053cfb5652fadc">
                        <edge COLOR="#f2a97b"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Load" FOLDED="false" POSITION="right" ID="4766e82c475094fb4b1ba416">
                        <edge COLOR="#f1ac80"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="MTU" FOLDED="false" POSITION="right" ID="7f447e7a0d175f5bd67b587c">
                        <edge COLOR="#f0a575"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Packet Loss" FOLDED="false" POSITION="right" ID="1a82dc65c92fc1b57e819551">
                        <edge COLOR="#f2ab7d"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Latency" FOLDED="false" POSITION="right" ID="dfaa9f84742213bfc84e1846">
                        <edge COLOR="#f2a371"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="Reliability" FOLDED="false" POSITION="right" ID="f9b728fc463ae1270c4bd2af">
                        <edge COLOR="#eea16f"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                </node>
            </node>
            <node TEXT="IPv6" FOLDED="false" POSITION="left" ID="39471c59196f123094168ab3">
                <edge COLOR="#ecd266"/>
                <font NAME="Helvetica" SIZE="50"/>
                <node TEXT="Address Type" FOLDED="false" POSITION="left" ID="8c923d06fad5a2cd5cb0920a">
                    <edge COLOR="#eed062"/>
                    <font NAME="Helvetica" SIZE="17"/>
                    <node TEXT="Multicast" FOLDED="false" POSITION="left" ID="070114f6e47f49e5b3c8c3ad">
                        <edge COLOR="#edce59"/>
                        <font NAME="Helvetica" SIZE="17"/>
                        <node TEXT="Addresses" FOLDED="false" POSITION="left" ID="6aae51d72fbbe4e546abb848">
                            <edge COLOR="#ecce66"/>
                            <font NAME="Helvetica" SIZE="20"/>
                            <node TEXT="FF02::1 is for all nodes on the local link" FOLDED="false" POSITION="left" ID="a51f2bf4093f25199ee956fe">
                                <edge COLOR="#eccd6c"/>
                                <font NAME="Helvetica" SIZE="20"/>
                            </node>
                            <node TEXT="FF02::2 is for all routers on the local link." FOLDED="false" POSITION="left" ID="4e1b2e40dd4b714163a29afc">
                                <edge COLOR="#ebce71"/>
                                <font NAME="Helvetica" SIZE="20"/>
                                <node TEXT="FF01::2 is for all routers on node-local
" FOLDED="false" POSITION="left" ID="defb859b41e06551a4954c6e">
                                    <edge COLOR="#e8c86a"/>
                                    <font NAME="Helvetica" SIZE="20"/>
                                </node>
                            </node>
                            <node TEXT="FF02::1:2 is for all DHCP relay agents on the local link.  DHCP agents forward these packets to other subnets" FOLDED="false" POSITION="left" ID="463ad7e7afe4647d19c0d108">
                                <edge COLOR="#edcd69"/>
                                <font NAME="Helvetica" SIZE="20"/>
                            </node>
                        </node>
                        <node TEXT="Represents a dynamic group of hosts" FOLDED="false" POSITION="right" ID="5293614ce8d195df3b9f095f">
                            <edge COLOR="#eecf64"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="Multicast address with an FF01::/16 are restricted to a single node" FOLDED="false" POSITION="left" ID="9468f3c0f75bf1cdd667ba0b">
                            <edge COLOR="#efcf5e"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="All multicast addresses have an FF00::/8 prefix" FOLDED="false" POSITION="left" ID="a8c2d6fa07d422e822ae8bed">
                            <edge COLOR="#ebc953"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="Link Local Multicast addresses have only an FF02::/16 prefix" FOLDED="false" POSITION="left" ID="1b7537e01cf2b8abfaead14d">
                            <edge COLOR="#eccd64"/>
                            <font NAME="Helvetica" SIZE="17"/>
                            <node TEXT="FF02 addresses are not forwarded by routers
" FOLDED="false" POSITION="left" ID="51a08f4450af4f92838145c6">
                                <edge COLOR="#ebcd6e"/>
                                <font NAME="Helvetica" SIZE="17"/>
                            </node>
                        </node>
                        <node TEXT="Packets sent to a multicast address are sent to all interfaces identified by that address.
" FOLDED="false" POSITION="left" ID="75fd53516e4a7ea35a400c34">
                            <edge COLOR="#ebcc60"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="There are no broadcast addresses in IPv6.  Multicast Addresses are used instead" FOLDED="false" POSITION="left" ID="2d797ce06df092d5ce2befab">
                            <edge COLOR="#f0d062"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                    </node>
                    <node TEXT="Anycast" FOLDED="false" POSITION="left" ID="d01cd8f2d3ded830a3f2fefb">
                        <edge COLOR="#eccb5c"/>
                        <font NAME="Helvetica" SIZE="17"/>
                        <node TEXT="Can be used to find the nearest server of a specific type (DNS, NTP, ..." FOLDED="false" POSITION="left" ID="2b8c1dc09b92115e1d3b1af7">
                            <edge COLOR="#ebc961"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="You can have a link-local, unique local, or global unicast address
" FOLDED="false" POSITION="left" ID="421100316b91f5e668f9b974">
                            <edge COLOR="#eecc66"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="Assigning the same unicast address to more than one interface makes it an anycast address" FOLDED="false" POSITION="left" ID="e99478c5e097fdd3223bb62e">
                            <edge COLOR="#eac452"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="Anycast is a unicast address that is assigned to more than one interface, typically belonging to different hosts" FOLDED="false" POSITION="left" ID="f46303d5e24cd640b9dc370f">
                            <edge COLOR="#ecc858"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                    </node>
                    <node TEXT="Unicast" FOLDED="false" POSITION="left" ID="705004d737006e27b979c5da">
                        <edge COLOR="#efd46f"/>
                        <font NAME="Helvetica" SIZE="17"/>
                        <node TEXT="Link Local" FOLDED="false" POSITION="left" ID="3ffe5d59992434816679905c">
                            <edge COLOR="#f0d476"/>
                            <font NAME="Helvetica" SIZE="13"/>
                            <node TEXT="Are used for automatic address configuration, for neighbor discovery, or for subnets that have no routers" FOLDED="false" POSITION="left" ID="7e231ab51aef072fe98f4a19">
                                <edge COLOR="#f2d57e"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                            <node TEXT="Link-local addresses can only be used on the same subnet
" FOLDED="false" POSITION="left" ID="9a87a993a58fec22bf145069">
                                <edge COLOR="#f2d478"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                            <node TEXT="Link-local addresses start with FE80::/10 prefix" FOLDED="false" POSITION="left" ID="a03b8a6122df0ae321e03b00">
                                <edge COLOR="#f0d06e"/>
                                <font NAME="Helvetica" SIZE="13"/>
                                <node TEXT="Includes any address beginning with FE8, FE9, FEA, FEB" FOLDED="false" POSITION="left" ID="4381118ee9ef54bcd2cb9a06">
                                    <edge COLOR="#f1d075"/>
                                    <font NAME="Helvetica" SIZE="13"/>
                                </node>
                            </node>
                            <node TEXT="All nodes must have at least one link-local address, although it can have multiple addresses" FOLDED="false" POSITION="left" ID="b0a1d5c69f4e7b5cb715ded2">
                                <edge COLOR="#f0d276"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                            <node TEXT="Do not use link-local IPv6 address on routed networks.  Routers never forward packets destined for link-local addresses to other subnets" FOLDED="false" POSITION="left" ID="fae119cf45691a3c70fa0271">
                                <edge COLOR="#eece6c"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                        </node>
                        <node TEXT="Unique Local" FOLDED="false" POSITION="left" ID="ccbb5ad13c3655454e6ca84b">
                            <edge COLOR="#efd479"/>
                            <font NAME="Helvetica" SIZE="13"/>
                            <node TEXT="Addressing with FC00 or FD00 prefix are unique local addresses" FOLDED="false" POSITION="left" ID="b6c3e05d199e771c49e468a4">
                                <edge COLOR="#f2d682"/>
                                <font NAME="Helvetica" SIZE="13"/>
                                <node TEXT="The other 40 bits are used for the Global ID" FOLDED="false" POSITION="left" ID="98e1bb9d4d55a275b11f68cf">
                                    <edge COLOR="#f3d789"/>
                                    <font NAME="Helvetica" SIZE="13"/>
                                </node>
                                <node TEXT="The remaining 16 bits in the prefix are used for subnet information" FOLDED="false" POSITION="left" ID="09bcec62c257e149a1d5be37">
                                    <edge COLOR="#f2d178"/>
                                    <font NAME="Helvetica" SIZE="13"/>
                                </node>
                            </node>
                            <node TEXT="Cannot be used on a Public network without Address Translation" FOLDED="false" POSITION="left" ID="eeeec361c312f430b55c4a60">
                                <edge COLOR="#f1d47b"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                            <node TEXT="Equivalent to private addressing on IPv4" FOLDED="false" POSITION="left" ID="9b9efc7009ac31abb41d7fed">
                                <edge COLOR="#efcf6d"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                            <node TEXT="Private addresses used for communication within a site or between limited number of sites that never cross a public network" FOLDED="false" POSITION="left" ID="1747ff02955d7309c708e7d8">
                                <edge COLOR="#eed178"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                        </node>
                        <node TEXT="Global Unicast" FOLDED="false" POSITION="left" ID="04a71967b11a973ae3d59bb1">
                            <edge COLOR="#f1d36d"/>
                            <font NAME="Helvetica" SIZE="13"/>
                            <node TEXT="Assigned to interfaces that are globally unique" FOLDED="false" POSITION="left" ID="dcb2c5d410a7bf1ab717b5c3">
                                <edge COLOR="#f1cf63"/>
                                <font NAME="Helvetica" SIZE="13"/>
                            </node>
                        </node>
                    </node>
                    <node TEXT="Loopback" FOLDED="false" POSITION="left" ID="21cb155732e098b5831271fb">
                        <edge COLOR="#eecd5e"/>
                        <font NAME="Helvetica" SIZE="17"/>
                        <node TEXT="The local loopback address for the local host is 0:0:0:0:0:0:0:1 (::1 or ::1/128)" FOLDED="false" POSITION="left" ID="717ac6070cf49883015a754d">
                            <edge COLOR="#ecc754"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="Not assigned to an interface" FOLDED="false" POSITION="left" ID="174a25ae1bee56380bb4db68">
                            <edge COLOR="#eeca5a"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                        <node TEXT="Can be used to verify if TCP/IP protocol stack is properly installed on the host" FOLDED="false" POSITION="left" ID="93ee812759c1573b767f1caa">
                            <edge COLOR="#efcb5d"/>
                            <font NAME="Helvetica" SIZE="17"/>
                        </node>
                    </node>
                </node>
            </node>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="UDP" FOLDED="false" POSITION="right" ID="484bc3c97157dc0aa19206eb" X_COGGLE_POSX="-4791" X_COGGLE_POSY="2141">
        <edge COLOR="#ead25c"/>
        <font NAME="Helvetica" SIZE="13"/>
        <node TEXT="No confirmation / handshake" FOLDED="false" POSITION="left" ID="4cc61a12ade8d1908ad985c9">
            <edge COLOR="#e9cd53"/>
            <font NAME="Helvetica" SIZE="13"/>
        </node>
        <node TEXT="User Datagram Protocol" FOLDED="false" POSITION="left" ID="7a0ef8e229670db52d8196b1">
            <edge COLOR="#ebce51"/>
            <font NAME="Helvetica" SIZE="13"/>
        </node>
        <node TEXT="Connectionless" FOLDED="false" POSITION="left" ID="adecf66c3ab742a29db73b4e">
            <edge COLOR="#e8ce5e"/>
            <font NAME="Helvetica" SIZE="13"/>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="TCP" FOLDED="false" POSITION="right" ID="7c8b7540b2ae8a60d1af9332" X_COGGLE_POSX="-4772" X_COGGLE_POSY="2678">
        <edge COLOR="#efd86b"/>
        <font NAME="Helvetica" SIZE="13"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="Wireless Networks" FOLDED="false" POSITION="right" ID="7799c7c789d9f71e3e5f231c" X_COGGLE_POSX="990" X_COGGLE_POSY="4531">
        <edge COLOR="#69b500"/>
        <font NAME="Helvetica" SIZE="40"/>
        <node TEXT="Wireless Standards (802.11)" FOLDED="false" POSITION="right" ID="8c1c9c682fc4fb949500a62b">
            <edge COLOR="#67ac01"/>
            <font NAME="Helvetica" SIZE="40"/>
            <node TEXT="802.11a" FOLDED="false" POSITION="right" ID="b3374d6a51bfaa9b3d78050e">
                <edge COLOR="#6db003"/>
                <font NAME="Helvetica" SIZE="40"/>
                <node TEXT="5GHz" FOLDED="false" POSITION="right" ID="6b4a282719848eb7de3568ae">
                    <edge COLOR="#6fb001"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="54Mbps" FOLDED="false" POSITION="right" ID="50391c9951b1ec2b8540af85">
                    <edge COLOR="#71b104"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="100ft" FOLDED="false" POSITION="right" ID="68c10f0c06522e1fcdf8bf11">
                    <edge COLOR="#6ba803"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="23 Channels" FOLDED="false" POSITION="right" ID="0b676e612c6735e3189edae7">
                    <edge COLOR="#6ba902"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="OFDM" FOLDED="false" POSITION="right" ID="08f039af78dc46a7580196af">
                    <edge COLOR="#6dac03"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
            </node>
            <node TEXT="802.11g" FOLDED="false" POSITION="right" ID="597cf47288db30d47305f28d">
                <edge COLOR="#68a902"/>
                <font NAME="Helvetica" SIZE="40"/>
                <node TEXT="54Mbps" FOLDED="false" POSITION="right" ID="5f4389d53fe458876cf8e8a5">
                    <edge COLOR="#6aa801"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="150ft" FOLDED="false" POSITION="right" ID="51a377b79fe9e351b3efb059">
                    <edge COLOR="#6ca904"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="2.4GHz" FOLDED="false" POSITION="right" ID="7f5dd1b053620b842734968b">
                    <edge COLOR="#639c03"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="11 Channels" FOLDED="false" POSITION="right" ID="a089e40490b68b26c91293ad">
                    <edge COLOR="#649e03"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="Modulation" FOLDED="false" POSITION="right" ID="d3dff6081800c17bf5d1725a">
                    <edge COLOR="#70b201"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="DSSS (at lower rates)" FOLDED="false" POSITION="right" ID="c0d42cf73618a98c60ec378e">
                        <edge COLOR="#68a304"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                    <node TEXT="OFDM, QPSK, BPSK (at higher rates)" FOLDED="false" POSITION="right" ID="4a2f933ced69d213b9fda641">
                        <edge COLOR="#77b900"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                </node>
                <node TEXT="802.11b Backwards Compatible" FOLDED="false" POSITION="right" ID="e11c7badafbddea795c556f4">
                    <edge COLOR="#71b500"/>
                    <font NAME="Helvetica" SIZE="41"/>
                </node>
            </node>
            <node TEXT="802.11n" FOLDED="false" POSITION="right" ID="62e4086e9b0bcfcade7347c2">
                <edge COLOR="#6db100"/>
                <font NAME="Helvetica" SIZE="40"/>
                <node TEXT="Frame Composition" FOLDED="false" POSITION="right" ID="306e5d38955c29cb95eacf91">
                    <edge COLOR="#6aa702"/>
                    <font NAME="Helvetica" SIZE="41"/>
                    <node TEXT="802.11n changes frame composition resulting in less overhead" FOLDED="false" POSITION="right" ID="5fa345714d1e3ee78c0cdd78">
                        <edge COLOR="#71ad04"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                </node>
                <node TEXT="600Mbps" FOLDED="false" POSITION="right" ID="d4c8268392dd2b7fdf765700">
                    <edge COLOR="#68a401"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="300ft" FOLDED="false" POSITION="right" ID="29cfde27e1dda116e3811391">
                    <edge COLOR="#6dad00"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="MIMO (Multiple Input Multiple Output)
" FOLDED="false" POSITION="right" ID="27a507356dddbddceef05be3">
                    <edge COLOR="#72b500"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="Allows up to 4 receiving and 4 sending antennas
" FOLDED="false" POSITION="right" ID="c8609015f515678e4099ec53">
                        <edge COLOR="#6fab02"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                    <node TEXT="Adds bandwidth by using multiple antennas

" FOLDED="false" POSITION="right" ID="87a231420737711a805c8b11">
                        <edge COLOR="#7abd00"/>
                        <font NAME="Helvetica" SIZE="38"/>
                    </node>
                </node>
                <node TEXT="Channel Bonding" FOLDED="false" POSITION="right" ID="edbecf2b5c748f4a7da1b3c9">
                    <edge COLOR="#68a500"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="2.4GHz - 11" FOLDED="false" POSITION="right" ID="0db90ad560ca38be7efd9c5a">
                        <edge COLOR="#73b003"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                    <node TEXT="5GHz - 23" FOLDED="false" POSITION="right" ID="6c7a56fdb244d3a2cf73c6c8">
                        <edge COLOR="#689e03"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                </node>
                <node TEXT="OFDM (and others)" FOLDED="false" POSITION="right" ID="1e157de5898463a562b36284">
                    <edge COLOR="#6faf00"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="802.11a/b/g Backwards Compatible (depending)" FOLDED="false" POSITION="right" ID="85339d59d5ba082c780e6dfb">
                    <edge COLOR="#76bb00"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
            </node>
            <node TEXT="802.11ac" FOLDED="false" POSITION="right" ID="93a894f33bf80e04ac79e728">
                <edge COLOR="#6aab02"/>
                <font NAME="Helvetica" SIZE="40"/>
                <node TEXT="150ft" FOLDED="false" POSITION="right" ID="fc8695181db66d0ba437de90">
                    <edge COLOR="#6caa01"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="1.3Gbps" FOLDED="false" POSITION="right" ID="aed92e936ca9f63db0cdae4d">
                    <edge COLOR="#6caa03"/>
                    <font NAME="Helvetica" SIZE="40"/>
                </node>
                <node TEXT="MU-MIMO" FOLDED="false" POSITION="right" ID="f2af1697faad60ecd6df56b7">
                    <edge COLOR="#6dad00"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="Multi-User Multiple Input Multiple Output
" FOLDED="false" POSITION="right" ID="b96dd57fb9a82d0bb36d9708">
                        <edge COLOR="#68a001"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                    <node TEXT="Allows multiple users to use the channel
" FOLDED="false" POSITION="right" ID="78f2d0c4619b7643b85614b9">
                        <edge COLOR="#78b900"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                    <node TEXT="Doubled the MIMO radio streams from 4 to 8
" FOLDED="false" POSITION="right" ID="2233b2084025d59181a2c1ce">
                        <edge COLOR="#70ad00"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                </node>
                <node TEXT="802.11b/g/n Backwards Compatible" FOLDED="false" POSITION="right" ID="6a07c1468181bf0e4434e66d">
                    <edge COLOR="#72b500"/>
                    <font NAME="Helvetica" SIZE="41"/>
                </node>
                <node TEXT="Frame Composition
" FOLDED="false" POSITION="right" ID="d863488d8dcca4a8024654c7">
                    <edge COLOR="#6faf02"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="802.11ac added 4 fields to the wireless frame, which identifies as very high throughput (VHT)" FOLDED="false" POSITION="right" ID="0854a1416861a86de3b547b1">
                        <edge COLOR="#76b504"/>
                        <font NAME="Helvetica" SIZE="34"/>
                    </node>
                </node>
                <node TEXT="Channel Bonding" FOLDED="false" POSITION="right" ID="4117b03720878faac513dd35">
                    <edge COLOR="#66a100"/>
                    <font NAME="Helvetica" SIZE="40"/>
                    <node TEXT="5GHz" FOLDED="false" POSITION="right" ID="b2c2797fa0be2c4c43901240">
                        <edge COLOR="#67a203"/>
                        <font NAME="Helvetica" SIZE="40"/>
                    </node>
                    <node TEXT="Up to 160MHz-wide channels
" FOLDED="false" POSITION="right" ID="bb29aa03c72a8f6e0ec14838">
                        <edge COLOR="#629601"/>
                        <font NAME="Helvetica" SIZE="41"/>
                    </node>
                </node>
            </node>
        </node>
        <node TEXT="Wireless Security" FOLDED="false" POSITION="left" ID="fe31a4754af398df3ca5497b">
            <edge COLOR="#73bf02"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="802.11b" FOLDED="false" POSITION="right" ID="343e045196385edf1dfb2945" X_COGGLE_POSX="3207" X_COGGLE_POSY="4588">
        <edge COLOR="#6db003"/>
        <font NAME="Helvetica" SIZE="40"/>
        <node TEXT="2.4GHz" FOLDED="false" POSITION="right" ID="53b5cc13db4245f7a4ee0f7d">
            <edge COLOR="#75b902"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
        <node TEXT="11Mbps" FOLDED="false" POSITION="right" ID="cdfbb0cc079bd972cc567fb1">
            <edge COLOR="#70b102"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
        <node TEXT="150ft" FOLDED="false" POSITION="right" ID="59497d97afb290c9a0ed4b78">
            <edge COLOR="#74b702"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
        <node TEXT="11 Channels" FOLDED="false" POSITION="right" ID="b486ce8671b7f6fc3b9a7014">
            <edge COLOR="#71b104"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
        <node TEXT="DSSS, CCK, DQPSK, DBPSK" FOLDED="false" POSITION="right" ID="8d4e9cd742386c6fb902c15e">
            <edge COLOR="#76b805"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
        <node TEXT="Not backwards compatible" FOLDED="false" POSITION="right" ID="a9dd11ba5dd6a905efccc6d6">
            <edge COLOR="#69a601"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
        <node TEXT="" FOLDED="false" POSITION="left" ID="7794afd4e9f3e52547be4c2c" X_COGGLE_JOINEDTO="8c1c9c682fc4fb949500a62b">
            <edge COLOR="#72b304"/>
            <font NAME="Helvetica" SIZE="40"/>
        </node>
    </x-coggle-rootnode>
</map>