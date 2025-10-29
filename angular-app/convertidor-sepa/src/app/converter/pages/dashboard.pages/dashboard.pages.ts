import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderComponent } from "../../util/header/header.component";
import { FooterComponent } from "../../util/footer/footer.component";


@Component({
  selector: 'app-dashboard.pages',
  imports: [HeaderComponent, RouterOutlet, FooterComponent],
  templateUrl: './dashboard.pages.html',
})
export class DashboardPages {

}
